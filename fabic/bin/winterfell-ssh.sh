#!/bin/bash

targethost="winterfell.local"
ethmac="bc:5f:f4:0d:a8:ab"
bcastaddr="192.168.1.255"

time (
  let itercount=0

  while true; do
    let itercount=$itercount+1

    echo "Iter. #$itercount -- ssh $targethost"

    ssh winterfell.local
    retv=$?

    if [ $retv -eq 0 ]; then
      echo "Dude, ssh exited correctly, have fun..."
      break
    fi

    echo "Dude, bad ssh exit status ($retv)."
    echo "Pinging host $targethost"

    if ! ping -c1 -W1 winterfell.local; then
      echo "Ping failed, trying to wake up $targethost with a magic packet (as root (sudo)) :"

      if ! type -p wol-e; then
        echo "WARNING: Executable 'wol-e' was not found in \$PATH."
        # We try anyway (may be root has it).
      fi

      sudo wol-e -m "$ethmac" -b "$bcastaddr" -p 9
      retv=$?

      if [ $retv -eq 0 ]; then
        echo "Dude, sent the magic packet ok."
      else
        echo "ERROR: Dude, \`sudo wol-e -m '$ethmac' -b "$bcastaddr" -p 9\` failed for some reason :-/"
      fi
    else
      echo "Ping succeeded, host shall be up."
    fi

    sleep 2
  done
)
