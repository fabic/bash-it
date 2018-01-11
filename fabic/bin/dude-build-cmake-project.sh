#!/bin/bash
#
# fabic/2016-06-20
# fabic/2017-12-21: Extracted from that LLVM/Clang project of mine.

# Synonym for $PWD, actually.
here="$PWD"

# Current source directory where a CMakeLists.txt resides.
there="$here"

# Consecutive '../' that lead from $here to $there.
# (done this so that we can have the `find ...` command at the end of this
#  script display files _relative from the original $here directory).
reldots=""

# For `cmake . --graphviz=build-deps.graph.viz`
graphviz_dotty="$(type -p dotty)"
graphviz_output_file="_graphviz/dep-graph.dot"
graphviz_enabled=0

echo -e "+-- \e[90m\$ \e[97m`basename $0` \e[37m$@\e[0m"

#
## Search for a CMakeLists.txt from the current dir.
## walking upward in parent directories until one is found.
#
# FIXME: WTF!? Strange Bash syntax error here with this `if ...`: "unexpected EOF" O_O`
# FIXME:  ` altered the loop so it's okay now.
#
#if [ ! -e "CMakeLists.txt" ]; then
  #echo "+- Current dir. '$there' has no CMakeLists.txt : Moving up a level to parent dir."
  while true; do
    if [ -f "CMakeLists.txt" ]; then
      # Display message only if we did move up in ancestry.
      [ "$there" != "$here" ] &&
        echo "| Found CMakeLists at dir. '$there'." &&
        echo "|  \` we were in '$here' initially."
      # Don't stop at the first .git dir/file found: search for the last .git
      # whose parent has no CMakeLists.
      [ -f "$there/../CMakeLists.txt" ] &&
        echo "|  \` parent dir. also has a CMakeLists.txt," &&
        echo "|     => continuing search further upward..." ||
          break # <-- FOUND (!)
    # .git may be files, which indicate we're in a Git submodule => continue.
    elif [ -f .git ]; then
      echo "| Reached dir. '$there' which has a .git file (most certainly this is a Git submodule ; CONTINUING SEARCH."
    # We _do_ stop however once we reach a .git/ directory.
    elif [ -d .git ]; then
      echo "| Reached dir. '$there' which has a .git/ subdir."
      echo "|  \`STOPPING NOW (as we found no CMakeLists.txt along the way up from within '$here')."
      exit 2
    elif [ ! -w "$there" ]; then
      echo "| Stumbled upon a non-writable directory '$there' (!)"
      echo "|  \` STOPPING NOW !"
    # We should never reach this since we would typically encounter a non-writable
    # dir. before.
    elif [ "x$there" == "x/" ]; then
      echo "| Oops! Reach filesystem root '/'"
      echo "|  \` (this is unexpected: this loop may be buggy, or not)."
      echo "|"
      echo "| (!!) STOPPING NOW (!!)"
      echo "+"
      exit 127
    fi

    cd .. || exit 1

    there="$PWD"
    reldots="../$reldots"
  done

  # Strip off the leading '/'
  # DON'T (!)
  #reldots="${reldots%%/}"
#endif


# Quickfix /me want Clang generally.
[ -z ${CC+x}  ] && type -p clang >/dev/null   &&
  export CC=clang    && echo -e "| \e[33m\$CC was set to $CC\e[0m"
[ -z ${CXX+x} ] && type -p clang++ >/dev/null &&
  export CXX=clang++ && echo -e "| \e[33m\$CXX was set to $CXX\e[0m"


# Target directory for out-of-tree build :
builddir="build"

# Defaults to empty string => do not pass -DCMAKE_BUILD_TYPE=...
# argument to CMake (user may have its own default,
# eventually set from its CMakeLists.txt)
# ~> This is set to "Release" if special arg. 'release' is provided.
buildtype=""

# FHS-like local/ dir.
localdir=""

## echoes
BE_VERBOSE_CHATTY=1
function echox() {
    if [ $BE_VERBOSE_CHATTY == 1 ]; then
        echo "$@"
    fi
}

# Whether or not we should wipe out the build/ dir. or not ;
# Defaults to "no" if build/CMakeCache.txt exists.
[ -e "$there/$builddir/CMakeCache.txt" ] &&
  do_rebuild="no" || do_rebuild="yes"

do_pause=0
do_break=0

cmake_binary="$( type -p cmake )"
ninja_binary="$( type -p ninja )"
make_binary="$( type -p make )"

# Default to Ninja if found in PATH.
[ -n "$ninja_binary" ] &&
    cmake_generator="Ninja" || cmake_generator="Unix Makefiles"

cmake_extra_args=( )
make_extra_args=( )


#
## Refuse to run at $HOME.
#
if [ "$there" = "$HOME" ]; then
    echo
    echo "~~ Dude: We're at \$HOME ($there), ain't doing no work here, rest, cheers."
    echo
    exit 1
elif [ "x$builddir" = "x" ]; then
  echo
  echo "!!! \$builddir='' is not set or empty !!! "
  echo
  exit 3
fi


# Parse command line arguments for both CMake, and eventually make/ninja
# (which are separated by '--')
#
# Consume a few special arguments which may be the CMake -G <generator>
# (for ex. 'ninja'), and 'rebuild'.
if [ $# -gt 0 ];
then
  while [ $# -gt 0 ];
  do
    case "$1" in
    "make")
        cmake_generator="Unix Makefiles"
        shift
        ;;
    "ninja")
        cmake_generator="Ninja"
        #echox "|   -> version `ninja --version`"
        shift
        ;;
    "rebuild")
        do_rebuild="yes"
        echo "| Rebuild asked (will remove the build dir. '$builddir')"
        shift
        ;;
    "release")
        builddir="rel-build"
        buildtype="Release"
        echo "|"
        echo -e "| \e[30;42m RELEASE BUILD REQUESTED \e[0m"
        echo "|"
        shift
        ;;
    "break")
        do_break=1
        shift
        ;;
    "pause") # TODO: impl. "pause=X"
        do_pause=1
        shift
        ;;
    "graphviz")
      [ -n "$graphviz_dotty" ] &&
          graphviz_enabled=1 || graphviz_enabled=0
        shift
        ;;
    *) # Stop once we fing something we don't recognize.
        break
    esac
  done

  # Consume extra. arguments for CMake, until we hit the '--' separator.
  while [ $# -gt 0 ];
  do
    arg="$1"
    shift

    cmake_extra_args=( "${cmake_extra_args[@]}" "$arg" )

    [ "$arg" == "--" ] && break
  done

  # Consume extra. arguments for make/ninja
  # (until we hit another '--' separator).
  while [ $# -gt 0 ];
  do
    arg="$1"
    shift

    make_extra_args=( "${make_extra_args[@]}" "$arg" )

    [ "$arg" == "--" ] && break
  done

  if [ $# -gt 0 ]; then
      echo "+-"
      echo "| WARNING: extraneous arguments were provided (neither for CMake nor Ninja); these will be ignored :"
      echo "|          $0 [...] $@"
      echo "+-"
  fi
fi


# Less echos for rebuilds, see Bash function 'echox'
[ "x$do_rebuild" != "xyes" ] &&
  BE_VERBOSE_CHATTY=0

echox "| Ok, CMake generator -G $cmake_generator"


## local/ FHS-style target installation dir.
# (for e.g. -DCMAKE_INSTALL_PREFIX=..., or ./configure --prefix=...)
if [ -e "$there/local" ];
then
  localdir="$there/local"
  echox "| Ok: found existing FHS-like 'local/' dir. at '$localdir'"
elif ["x$do_rebuild" != "xyes" ];
then
  echo "| FHS-like 'local/' dir. does not exist at '$there/local' ; "
  read -p "|  \` Would you like to create one ? [y/n] " answer
  if [[ $answer =~ "y*" ]]; then
    if ! mkdir "$there/local"; then
      echo "|      > FAIL: Could not create '$there/local'."
      exit 2
    fi
    localdir="$there/local"
    echo "| Ok: FHS-like 'local/' dir. is now '$localdir'  ( \$localdir )."
  fi
fi


echox "| Entering '$there/'."
pushd "$there" >/dev/null

echox
echox "|"
echox "| Current dir. : `pwd`"
echox "|"


# Auto. CMAKE_INSTALL_PREFIX if ./local/ directory exists.
[ ! -z "$localdir" ] &&
  cmake_extra_args=(
    -DCMAKE_INSTALL_PREFIX="$localdir"
    "${cmake_extra_args[@]}"
    )


# Print out arguments for both CMake and Make/Ninja.
if [ $BE_VERBOSE_CHATTY -gt 0 ];
then
  if [ ${#cmake_extra_args[@]} -gt 0 ]; then
    echox "| Additional CMake arguments :"
    echox "|"
    echox "|   ${cmake_extra_args[@]}"
    echox "|"
  fi

  if [ ${#make_extra_args[@]} -gt 0 ]; then
    echox "| Additional $cmake_generator arguments :"
    echox "|"
    echox "|   ${make_extra_args[@]}"
    echox "|"
  fi
fi


cmake_args=(
  -Wdev
  --warn-uninitialized
  --clean-first
  -G "$cmake_generator"
  # -DFABIC_LOCAL_DIR="$localdir"
  # -DCMAKE_BUILD_TYPE=Debug
  # -DCMAKE_BUILD_TYPE=RelWithDebInfo
  # -DCMAKE_BUILD_TYPE=MinSizeRel
  #  ^ Leave that to users: Use the default build type that is eventually
  #    configured by CMakeLists.txt
  #  ^ EDIT: see below if $buildtype non-empty.
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
)

# Set CMAKE_BUILD_TYPE if non-empty.
[ ! -z "$buildtype" ] &&
  cmake_extra_args=(
    -DCMAKE_BUILD_TYPE="$buildtype"
    "${cmake_extra_args[@]}"
    )

# Don't !
[ "$do_rebuild" == "yes" ] && graphviz_enabled=0

# Graphviz
if [ $graphviz_enabled -gt 0 ]; then
  echox "| Graphviz enabled. \`dotty\` is ${graphviz_dotty}"
  echox "|  \` Run: dotty '$graphviz_output_file'"
  cmake_args=( "${cmake_args[@]}"
    --graphviz="$graphviz_output_file"
   )
fi

# Append user-provided arguments last.
cmake_args=( "${cmake_args[@]}"
  "${cmake_extra_args[@]}"
  ..
 )

 make_args=( "${make_extra_args[@]}" )


# Remove build/ subdir. only if no command line
# arguments were provided (i.e. targets) :
if [ "x$do_rebuild" == "xyes" ] &&
   [ -d "$builddir" ];
then
    echo "| Removing $builddir/ directory."
    rm -rf "$builddir"
fi


# Create BUILD/ if not exists :
if [ ! -d "$builddir" ];
then
    echo "| Creating $builddir/ sub-directory."
    mkdir "$builddir" ||
      exit 126
fi


# Enter BUILD/ dir.
if ! cd "$builddir" ;
then
    echo "| FAILED: could not ch. dir. into '$builddir/'"
    exit 125
fi


echox "|"
echox "+-- Running CMake  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+"
echo    "+-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+"
echo -e "|\e[97m   $cmake_binary \\"
echo -e "|     ${cmake_args[@]} \e[0m"
echo    "+-- -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -+"

if [ $BE_VERBOSE_CHATTY -eq 1 ]; then
    echox "|   » CMAKE_EXPORT_COMPILE_COMMANDS=ON"
    echox "|     ^ so that we get a 'compilation_commands.json' file"
    echox "|       See http://clang.llvm.org/docs/HowToSetupToolingForLLVM.html"
    echox "|     ^ for us to play with Clang Tooling abilities (which needs to build"
    echox "|        a “compilation database”)."
    echox "|"
    echox "|   » You may want to specify the build type :"
    echox "|"
    echox "|         -DCMAKE_BUILD_TYPE=Debug         "
    echox "|         -DCMAKE_BUILD_TYPE=RelWithDebInfo"
    echox "|         -DCMAKE_BUILD_TYPE=MinSizeRel    "
    echox "+-"
fi

echo

#
## RUNNING CMake !
#
"$cmake_binary" \
  "${cmake_args[@]}"

retv=$?
if [ $retv -gt 0 ]; then
    echo
    echo "| CMake failed, exit status: $retv"
    echo "+-"
    exit 125
fi


# PAUSE ?
if [ $do_pause -eq 1 ]; then
  echo "~~ PAUSE 1.5s ~~"
  sleep 1.5
# TODO: impl. arg. "pause=2"
elif [ $do_pause -eq 2 ]; then
  read -p "CMake completed, proceed with actual build (make/ninja) ?"
fi


# BREAK ? (exit script here, i.e. do not run make/ninja).
if [ $do_break -gt 0 ]; then
  echo
  echo    "+-"
  echo -e "| \e[93m ~~ BREAK (not running Make/Ninja) ~~\e[0m"
  echo    "|"
  echo -e "|   \e[97mcmake --build $builddir/ [--target <target>]\e[0m"
  echo    "|"
  echo -e "|   \e[97mcmake --build $builddir/ --target help\e[0m"
  echo    "+-"
elif [ "$cmake_generator" == "Ninja" ];
then
  echox
  echox "+-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+"
  echox "|   Ninja"
  echox "+-- -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -+"
  echo

  time \
    ninja \
      "${make_extra_args[@]}"

  retv=$?
  if [ $retv -gt 0 ]; then
      echo
      echo "| Ninja failed, exit status: $retv"
      echo "+"
      exit 125
  fi

  echox
  echox "| Ninja finished, ok"
  echox "+-"
elif [ "$cmake_generator" == "Unix Makefiles" ];
then
  echox
  echox "+-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+"
  echox "|   MAKE"
  echox "+-- -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -+"
  echo

  time \
    make \
      "${make_extra_args[@]}"

  retv=$?
  if [ $retv -gt 0 ]; then
      echo
      echo "| make failed, exit status: $retv"
      echo "+"
      exit 125
  fi

  echox
  echox "| make completed, ok"
  echox "+-"
else
  echo "|"
  echo "+- $0: ERROR: Unknown \"generator\" \$cmake_generator='$cmake_generator'"
  exit 3
fi


# move out of BUILD/ (return to previous dir.)
echox "+~~> popd !" &&
  popd >/dev/null


echo
echo "+- List of executable files under '$there/$builddir' :"
echo "|"

  #find "$builddir/" \
  # ^ this was fine, but having built binary paths be displayed _relative from_
  #   the dir. this script was launched is quite useful.

  # Just back to whence we came and search.
  cd "$here" &&
  find "$reldots$builddir" \
    \( -type d -name CMakeFiles -prune \) \
    -o -type f \
         \(    \
             -perm -a+x  \
          -o -name \*.a  \
          -o -name \*.ko \
          -o -name \*.la \
          -o -name \*.so \
         \) \
    -print0 | \
      xargs -0r ls -ltrh | \
        sort -k9         | \
        sed -e 's@^@|    &@'

# Tell user how to run `dotty`.
if [ $graphviz_enabled -gt 0 ] && [ $BE_VERBOSE_CHATTY -gt 0 ]; then
  echo "+-"
  echo -e "| \e[34;7mGraphviz dependency graph generation :\e[0m"
  echo "|"
  if [ -e "$builddir/$graphviz_output_file" ]; then
    echo "|"
    echo "|   - dotty: $graphviz_dotty"
    echo "|   - File: '$graphviz_output_file'"
    echo "|   - generate with, for ex.:"
    echo "|"
    echo -e "|       \e[92mdotty '$builddir/$graphviz_output_file'\e[0m"
  else
    echo -e "| \e[91m \` ERROR: Graphviz was enabled but the output file '$graphviz_output_file' does not exist or something -_- \e[0m"
  fi
fi

echo "|"
echo -e "+-- $0 : \e[7mFINISHED\e[0m, exit status: \e[97m$retv\e[0m"
echox

exit $retv

# vim: et ts=2 sw=2 sws=2
