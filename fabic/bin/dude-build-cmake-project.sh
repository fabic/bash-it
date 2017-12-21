#!/bin/bash
#
# fabic/2016-06-20
# fabic/2017-12-21: Extracted from that LLVM/Clang project of mine.

# Current source directory :
here="$( pwd )"

there="$here"

# Target directory for out-of-tree build :
builddir="build"

# FHS-like local/ dir.
localdir=""

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
if [ "$here" = "$HOME" ]; then
    echo
    echo "~~ Dude: You're at \$HOME ($here), ain't doing nothing, cheers."
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
echox "+-- $0 $@"
echox "|"
echox "| Current dir. : `pwd`"
echox "|"


# CMAKE_INSTALL_PREFIX
[ ! -z "$localdir" ] &&
  cmake_extra_args=( ${cmake_extra_args[@]} -DCMAKE_INSTALL_PREFIX="$localdir")


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
  -G "$cmake_generator"
  #-DFABIC_LOCAL_DIR="$localdir"
  #-DCMAKE_BUILD_TYPE=Debug
  #-DCMAKE_BUILD_TYPE=RelWithDebInfo
  #-DCMAKE_BUILD_TYPE=MinSizeRel
  # ^ Leave that to users: Use the default build type that is eventually
  #   configured by CMakeLists.txt
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
  -Wdev
  --warn-uninitialized
  --clean-first
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
echo "+-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -+"
echo "|   $cmake_binary \\"
echo "|     ${cmake_args[@]}"
echo "+-- -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -+"

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


#read -p "CMake completed, proceed with actual build (make/ninja) ?"


if [ "$cmake_generator" == "Ninja" ];
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
echo "+- List of executable files under '$here/$builddir' :"
echo "|"

  find "$builddir/" \
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

echo "|"
echo "+-- $0 : FINISHED, exit status: $retv"
echox

exit $retv

# vim: et ts=2 sw=2 sws=2
