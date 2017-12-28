#!/bin/bash
#
# FABIC/2017-12-24

findcmd=( find "$@" )

if [ $# -lt 1 ]; then
  echo "+- #0"
  echo "|"
  echo "| Find C/C++ source code files, and run Clang over these."
  echo "| > If exit status is 0 => file was parsed w/o errors and is output to STDOUT."
  echo "| > If exit status <> 0 => file was parsed with errors."
  echo "|"
  echo "| Usage: `basename "$0"` <all arguments are for \`find ...\`>"
  echo "|"
  echo "| Examples :"
  echo "|"
  echo "|   `basename "$0"` /usr/include/boost/ -maxdepth 2 -type f -name \*.hpp"
  exit 1
fi

let i=0

while read fil; do
  let i=i+1
  clang++ -std=c++17 -c -O0 -fsyntax-only "$fil"
  retv=$?
  1>&2 echo "#$i) [$retv]: $fil"
  if [ $retv -eq 0 ]; then
    echo "$fil" | sed -e 's@^/usr/include/@#include <@;s@$@>@'
  else
    echo "$fil" | sed -e 's@^/usr/include/@// #include <@;s@$@>@'
  fi
done < <("${findcmd[@]}")

