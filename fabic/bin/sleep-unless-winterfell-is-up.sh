#!/bin/bash
#
# FABIC/2017-12-14

let count=0

while true; do
  if ! ping -q -c1 winterfell.local > /dev/null ; then
    echo -n 'X'
    let count=$count+1
    if [ $count -ge 3 ]; then
      echo "`date` : GOING TO SLEEP NOW."
      sudo systemctl hybrid-sleep
      echo "`date` : BACK FROM SLEEP I AM."
      let count=0
    fi
  else
    echo -n '.'
    [ $count -gt 0 ] && let count=0
  fi

  sleep 5
done
