#!/bin/sh
#
# See @link http://clang.llvm.org/docs/IntroductionToTheClangAST.html
#
# FABIC 2014-2017

# Synonym for $PWD, actually.
here="$PWD"

clang_cmd=( clang++
    -std=c++1z
    -Og
    -fparse-all-comments
    -Wall
    -pedantic
    -Weverything
    # ^ http://clang.llvm.org/docs/UsersManual.html#enabling-all-diagnostics
    -Wmissing-field-initializers
    -Wnon-virtual-dtor
    -Wdelete-non-virtual-dtor
    -Woverloaded-virtual

    -fcolor-diagnostics
    -fdiagnostics-show-category=name
    -fdiagnostics-show-template-tree

    -femit-all-decls
  )

# Auto. add an eventual ./include/ directory.
if [ -d include ]; then
  echo "+- Adding -Iinclude found in current directory '$here'."
  clang_cmd=( "${clang_cmd[@]}" -Iinclude )
fi

clang_args=()

# Display usage notes
# ^ but do not stop now since we permit invocation with no arguments at all.
if [ $# -lt 1 ]; then
  (
    this="`basename "$0"`"
    echo "+-"
    echo "| WARNING: NO ARGUMENTS PROVIDED (for Clang)."
    echo "|  \`-> passing \`-x c++ -c -\` so that you may read source code from STDIN."
    echo "|"
    echo "|  For example: \$ $this < test.cpp"
    echo "|"
    echo "+-"
    echo "| Usage: $this [<clang arg1> ]* [-- [syntax|s|dump|d|verbose|v]]"
    echo "|"
    echo "| Examples:"
    echo "|"
    echo "|   \$ $this test.cpp        ( default: -Xclang -ast-dump -fsyntax-only )"
    echo "|   \$ $this test.cpp -- s   ( -fsyntax-only )"
    echo "|   \$ $this test.cpp -- d   ( -Xclang -ast-dump )"
    echo "|   \$ $this test.cpp -- v   ( -v -Wp,-v -Wl,--verbose )"
    echo "|"
    echo "+"
  ) 1>&2
fi

# Consume arguments that are for Clang until
# we eventually hit a "--" separator.
while [ $# -gt 0 ];
do
  arg="$1"
  shift

  if [ "$arg" == "--" ]; then
    break;
  fi

  clang_args=( "${clang_args[@]}" "$arg")
done

# Extraneous arguments (after the "--" separator)
# are for us.
if [ $# -gt 0 ]; then
  while [ $# -gt 0 ];
  do
    arg="$1"
    shift

    case "$arg" in
      "syntax"|s)
        clang_cmd=( "${clang_cmd[@]}" -fsyntax-only )
        ;;
      "dump"|d)
        clang_cmd=( "${clang_cmd[@]}" -Xclang -ast-dump )
        ;;
      "verbose"|v)
        clang_cmd=( "${clang_cmd[@]}" -v -Wp,-v -Wl,--verbose )
        ;;
    esac
  done
# No arguments => default invocation.
else
  clang_cmd=( "${clang_cmd[@]}" -Xclang -ast-dump -fsyntax-only )
fi


# Special invocation with no arguments for Clang =>
# invoke Clang with `-x c++ -c -` so as to read source
# code from standard input.
if [ ${#clang_args[@]} -lt 1 ]; then
  (
    this="`basename "$0"`"
    echo "+-"
    echo "| FYI: No arguments provided for Clang,"
    echo "|  \`-> passing \`-x c++ -c -\` so that source code is read from STDIN."
    echo "+"
  ) 1>&2

  clang_cmd=( "${clang_cmd[@]}" -x c++ -c - )
fi

clang_cmd=( "${clang_cmd[@]}" "${clang_args[@]}" )

echo "+~~> COMMAND :"
echo "|"
echo "| ${clang_cmd[@]}"
echo "+-"
echo

exec "${clang_cmd[@]}"
