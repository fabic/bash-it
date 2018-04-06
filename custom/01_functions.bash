# custom/01_functions.bash @ https://github.com/fabic/bash-it
#
# F.2011-08-16 : From LFS (http://www.linuxfromscratch.org/blfs/view/stable/postlfs/profile.html)

# Functions to help us manage paths.  Second argument is the name of the
# path variable to be modified (default: PATH)
pathremove () {
        local IFS=':'
        local NEWPATH
        local DIR
        local PATHVARIABLE=${2:-PATH}
        for DIR in ${!PATHVARIABLE} ; do
                if [ "$DIR" != "$1" ] ; then
                  NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
                fi
        done
        export $PATHVARIABLE="$NEWPATH"
}

pathprepend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

pathappend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
}

# “Vim in dir.” :
#    Open Vim in the specified directory,
#    by ch. dir. into it first.
# F.2011-11-22
vin() {
    local dest="$1"
    pushd "$dest" &&
        shift &&
        vim "$@" &&
    popd
}

# x == xdg-open
# ^ I never use 'X' for anything from the command line, like e.g. x=...
function x() {
    xdg-open "$@"
}

# `f` : Fetch some HTTP resource with Curl (output piped through less).
function f() {
  local -a args=( "$@" )
  curl --dump-header /dev/stderr \
    "${args[@]}" \
    | less
    #-o /dev/stdout \
}

# `w` : Quite locate file(s).
#
# Locate files in arguments :
#   1) exists in/from the current directory ;
#   2) search for an executable script in $PATH (`type -p ...`) ;
#   3) if argument is less than 5 characters => output as-is ;
#   4) Resort to `locate ...` for finding the most recently modified files
#      (limit to at most 10);
#
# Note that the current dir. is always striped off (${arg#$PWD/}) when applicable.
#
# FABIC/2017-12-18
function w() {
    local arg
    local fil
    while [ $# -gt 0 ]; do
        arg="$1"

        shift

        # Skip "switches" like -h --help -etc.
        if [ "${arg#-}" != "$arg" ]; then
            echo "$arg"
            continue
        fi

        # (1) First check if file pathname exists _from within_ the current
        #     directory.
        if [ -e "$arg" ]; then
            echo ${arg#$PWD/}
            continue
        fi

        # (2) Search for an executable shell script in $PATH.
        #     FIXME: Filter out binary files (!!)
        fil="$(type -p "$arg")"

        if [ -n "$fil" ]; then
            echo "${fil#$PWD/}"
            continue
        fi

        # (3) Pass arguments that are less that 5 characters as-is,
        #     because we'll be using `locate` below.
        if [ ${#arg} -lt 5 ]; then
            echo "${arg#$PWD/}"
            continue
        fi

        # If arg. does not contain slashes, `locate` file by matching
        # only it's base name (ignoring the dir. path components).
        # (locate's default behaviour is to match against the whole pathname).
        # (!) limit to the 10 most recently modified files.
        [ "${arg//\//}" != "$arg" ] && bn="" || bn="-b"

        if [ `locate $bn -c -n1 --regex "$arg"` -gt 0 ]; then
            while read fil; do
                echo "${fil#$PWD/}"
            done < <(locate $bn -0 --regex "$arg" | xargs -0r ls -t | head -n10)
            continue
        fi

        # No file found => return argument as-is.
        echo "$arg"
    done
}

# Check that W is not already defined, just in case.
if false; then
    type_of_w="`type -t W`"
    if [ ! -z "$type_of_w" ]; then
        echo "~~> WARNING: ${BASH_SOURCE[0]}: \`W\` is already defined (is-a: $type_of_w)."
        # Display bash function content.
        if [ "$type_of_w" == "function" ]; then
            type W | sed -e 's/^/             /'
        fi
    fi
    unset type_of_w
fi

## `W` : Find source code files.
#
# Usage: W [<path> ...]
#
# Examples :
#   $ W
#   $ W src include
#   $ W /usr/include
#
# Note that arguments are all passed to `find` _before_
# the filter expressions => hence these may be other things
# than just a list of locations to search for.
#
# Files are returned sorted by modification time (most recent first).
function W() {
    local locations=( "$@" )
    # Extended-grep compatible reg. ex.
    local regex=".*\.(c|h|cc|hh|cpp|hpp|cxx|hxx|h\.inc|hxx\.inc|s|rs|js|py|php|rb)$"
    local find_args=(
        "${locations[@]}"
             # Ignore all dotted '.xxx/' dirs.
             #   & CMakeFiles/ sub-directories.
             \( -type d \( -name '.?*' -o -name "CMakeFiles" \) -prune \)
          -o \( -type f \( -regextype egrep -iregex "$regex" \) -print \)
      )
      ( find "${find_args[@]}" ||
          (>&2 echo -e "\e[31;1;7m WARNING: \e[0;91m Bad \`find\` exit status: \e[97m$?\e[0m")
      ) | sed -e 's@^\./*@@' \
        | xargs -r -d\\n ls -1t
        # ^ Strip the eventual leading './' (which is boring).
        # ^ Sort: most recently modified files first.
      # ^ NOTE: Pipes do shadow `find` exit status (we can't catch errors).
}

# Remove the 'v' shell alias that was set in `aliases/available/vim.aliases.bash`
[ "`type -t v`" == "alias" ] && unalias v

# `v` ~ quick vim open file(s) searched with `w`.
function v() {
    vim $(w "$@")
}

# `V` (capital 'V') ~ Quick Vim open source code files, searched with `W`.
function V() {
    vim $(W "$@")
}

# `ww [<count>|2]` : Lists the <count> (default 2) most recently modified files
#                    of a Git subtree.
function ww() {
  local count=${1:-2}
  git ls-files -z |
    xargs -0r ls -1t |
      head -n$count
}

# `vv` : Open G/Vim with the two most recently modified files of a Git subtree.
#        (arguments are passed to Vim).
function vv() {
  local _g=
  [ ! -z "$DISPLAY" ] && local _g="-g"
  v $_g -O `ww` "$@"
}

# `wi` : What is <thing>.
function wi() {
  local thing="$1"
  local type="$( type -t "$thing" )"
  echo "'$thing' is-a '$type'"
  if [ "$type" == "file" ]; then
    for fil in "$( type -p "$thing" )"; do
      file "$fil"
    done
  fi
}


# TODO: review that ooold thing.
# NOTE: See fabic/bin/prox script.
proxy_unset() {
    #local -a varlist=( HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY NO_PROXY )
    local -a varlist=( $(env | grep -io '^.\+_proxy=') )
    local var
    varlist=${varlist[*]%=}
    for var in ${varlist[*]}; do
        #echo $var ${!var}
        #continue
        if [ -v $var ]; then
            echo "unset $var (${!var})"
            unset -v $var
        fi
    done
}

# TODO: Function that used to emit a beep: edit so that it does that + sends some desktop notification or sthg.
# F.2014-09-16
function hey() {
	local count=${1:-1}
	local sound=${2:-snap}
	local file="~/${sound}.wav"
	[ ! -r "$file" ] && file=~/snap.wav
	for(( ; count>0 ; count-- )); do
		aplay $file 2> /dev/null
	done
}

# @see alias tree='find . -print | sed -e '\''s;[^/]*/;|____;g;s;____|; |;g'\'''
function ftree()
{
	local -a in_dirs
	in_dirs=( $1 ) ; shift
	find "${in_dirs[@]}" -type d ${@:+-o \( "$@" \)} |
		sort -df |
		sed -e 's@[^/]*/@|__@g;s@__|@ |@g'
		#cat
	return $?
}

# Ch.dir. to the directory specified as 1st argument, hence `cd -P ...`
# But: if target is a file, then ch.dir. into the containing directory.
# Also, if target is a symlink, then attempt to jump into the pointed to dir.
function cdp()
{
    if [ -L "$1" ]; then # BEWARE! RECURSION!
        cdp "$(readlink -f "$1")"
    elif [ ! -d "$1" ]; then
        cd -P "$(dirname "$1")"
    else
        cd -P "$1"
    fi
}

# vi: ft=sh et ts=2 sts=2 sw=2
