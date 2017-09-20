#!/usr/bin/env bash
#
# FABIC/2017-03-30

clion_sh=""

# Dumb: sort by time, most recent first.
puppies=(
  $(type -p clion.sh)
  $(ls -1t {$HOME/.local,/opt,/usr/local}/clion-*/bin/clion.sh 2> /dev/null)
)

if [ ${#puppies[*]} -lt 1 ]; then
  echo "| Could not find clion.sh startup script -_-"
fi

#clion_sh=${puppies[0]}
# ^ can't: _this_ script is also named clion.sh
#          so we have to loop over the list.
for (( i=0; i < ${#puppies[*]}; i++ )) ;
do
  clion_sh=${puppies[$i]}
  [ "$clion_sh" == "${BASH_SOURCE[0]}" ] && continue || break
done

if [ -z "$clion_sh" ]; then
  echo "| clion.sh startup script wasn't found."
  exit 1
fi

echo "| Got clion.sh : $clion_sh"

exec "$clion_sh"

