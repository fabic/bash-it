#/bin/bash
#
# FABIC / 2018-01-05

# Write to stderr.
function echox() {
  >&2 echo "$@"
}

this="`basename "$0"`"

echox "+-- $this $@"

if [ $# -lt 1 ]; then
  echox "|"
  echox "| Usage:"
  echox "|"
  echox "|   $ $this <regex> [<path|library>] ..."
  echox "|"
  echox "+--"
  exit 1
fi

symbol="$1"
shift

paths=( "$@" )

echox "| Will search for symbol matching '$symbol'"
echox

for path in "${paths[@]}"; do

  while read library;
  do
    libname="`basename "$library"`"

    echox -en "\e[33m+~>\e[0m \e[94m$libname\e[0m"

    # Skip symlinks
    if [ -L "$library" ]; then
      echox -en " \e[97m--symlink-->\e[0m [\e[36m`readlink "$library"`\e[0m] \e[95m(skipping)\e[0m\n"
      # TODO: check broken symlinks ?
      continue
    # Skip if has no +x permission.
    elif [ ! -x "$library" ]; then
      echox -en " : \e[91m File '\e[2m$library\e[91m' has no exec. bit, \e[95mSKIPPING\e[91m)\e[0m\n"
      continue
    else
      echox -en " -- \e[90m$library\e[0m \n"
    fi

    #readelf -sW "$library"
    # `nm` is much slower, but clever:
    #      > use -u (--undefined-only for displaying only external symbols).
    #      > or --defined-only
    #      > -g will list all external symbols.
    #      > -l will display source code information if available.
    #nm -Cgl --defined-only "$library" \
    objdump --syms -wC "$library" \
      | grep -E "$symbol"

    retv=$?
    if [ $retv -eq 0 ]; then
      echo -en "\e[92m^ $library matches.\e[0m\n"
    fi

  done < \
          <( if [ -d "$path" ]; then
               echox "| Listing libraries in '$path'."
               find "$path/" \( -type f -o -type l \) \
                 -regextype egrep -iregex ".*\.*.so(\.[0-9])*$" \
                 -print
             elif [ -f "$path" ]; then
               library="$path"
               echo "$library"
             fi | \
                  sort )

  #   for lib in "$library" ; do
  #     echo "# Library: $library"
  #     readelf -sW $lib || break; done
done
