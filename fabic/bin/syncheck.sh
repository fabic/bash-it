#!/bin/bash
#
# FABIC 2018-01-22

# TODO: recurs up
if [ ! -e .git ]; then
  echo "OUCH!"
  exit 1
fi

# Arguments are for our `astdump` script.
args="$@"

# List modified files, most recent first.
files=( $(git status -uno --porcelain | awk '{print $2}' \
            | sort -u \
            | xargs -r -d\\n ls -1t) )

# TODO: and/or `git ls-files` ...

sources=()
headers=()
inc_headers=()
impls=()
others=()

# Partition the set of files differentiating between header files
# and implementation files.
# ^ because we want to process header files first.
for file in "${files[@]}"; do
  if [[ $file =~ \.(h|hh|hpp|hxx)$ ]]; then
    headers=( "${headers[@]}" "$file" )
    sources=( "${sources[@]}" "$file" )
  elif [[ $file =~ \.(h|hh|hpp|hxx)\.inc$ ]]; then
    inc_headers=( "${inc_headers[@]}" "$file" )
    # sources=( "${sources[@]}" "$file" )
    # ^ we're skipping these intently.
  elif [[ $file =~ \.(c|cc|cpp|cxx)$ ]]; then
    impls=( "${impls[@]}" "$file" )
    sources=( "${sources[@]}" "$file" )
  else
    others=( "${others[@]}" "$file" )
  fi
done

if true; then
  for file in "${sources[@]}"; do
    echo -e "\e[32m~~> File:\e[0m $file"
    astdump "${args[@]}" "$file" -- syntax
    retv=$?
    if [ $retv -gt 0 ]; then
      echo
      echo -e "\e[31m~~> Syntax check failed for file:\e[0m $file"
      echo
      # break
    fi
  done
else
  echo "TODO: ??"
fi
