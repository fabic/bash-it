#!/bin/bash
#
# FABIC/2017

ST_BIN="$( type -P sublime_text )"

# Not found in path.
if [ -z "$ST_BIN" ]; then
  # Search under /opt
  if [ -x /opt/sublime_text/sublime_text ]; then
    ST_BIN=/opt/sublime_text/sublime_text
  fi
fi

# Check if binary found.
if [ -z "$ST_BIN" ]; then
  (
    echo -e "\n\nERROR: Dude, I'm '${BASH_SOURCE[0]}' here talking,"
    echo -e "         and well, I did my best, which ain't much admittedly,"
    echo -e "         so I'll try to go straight to the point here :"
    echo
    echo -e "         You see, I could find the executable file for Sublime Text."
    echo
    echo -e "         Exiting now."
    echo
    echo -e "         Homepage is : https://www.sublimetext.com/"
    echo
  ) >&2
  exit 127
fi

>&2 echo "Dude, exec. $ST_BIN, have fun ;-"

exec "$ST_BIN" "$@"

