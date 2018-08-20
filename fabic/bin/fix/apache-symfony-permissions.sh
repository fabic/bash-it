#!/bin/bash
#
# F/2018-05

NonRootUser="`whoami`"

if [ -n "${SUDO_USER+x}" ]; then
  NonRootUser="$SUDO_USER"
  echo "Ok, you're sudoing this, coming from user: $SUDO_USER"
  echo "   \` => Setting \$NonRootUser = '$NonRootUser'"
fi

# TODO: Else we may take the NonRootUser value from a cli arg.

if [ "$NonRootUser" = "root" ]; then
  echo "ERROR: This script is being run as root, and we couldn't infer a value for \$NonRootUser"
  exit 1
fi

dirlist=(
  app/cache
  app/logs
  var/cache
  var/log
  tmp
  web
  #public/_wdt/
)

for dir in "${dirlist[@]}"; do
  # setfacl -R -m u:http:rwX -m u:`whoami`:rwX var/cache/ var/logs/ tmp/
  # setfacl -dR -m u:http:rwX -m u:`whoami`:rwX var/cache/ var/logs/ tmp/
  if [ ! -d "$dir" ]; then
    echo "SKIPPING non-existing dir. '$dir'"
    continue
  fi

  # TODO: -m u:`whoami`:rwX <-- we need this but this script is run as root (sudo)
  # TODO: ^ find out a good way to specify the unprivileged user name: probably $SUDO_USER.

  cmd=( setfacl -R -m u:http:rwX -m "u:$NonRootUser:rwX" "$dir" "$dir" )
  echo "# Running: \`${cmd[@]}\`"
  "${cmd[@]}"
  retv=$?
  if [ $retv -gt 0 ]; then
    echo "WARNING: Non-zero exit status: $retv"
    read -p "~~ Hit any key to proceed regardless (or Ctrl-C to abord this script) ~~"
    echo
  else
    echo "# ^ done ( \`${cmd[@]}\` )."
    echo
  fi

  # Defauls (-d).
  cmd=( setfacl -dR -m u:http:rwX -m "u:$NonRootUser:rwX" "$dir" )
  echo "# Running: \`${cmd[@]}\`"
  "${cmd[@]}"
  retv=$?
  if [ $retv -gt 0 ]; then
    echo "WARNING: Non-zero exit status: $retv"
    read -p "~~ Hit any key to proceed regardless (or Ctrl-C to abord this script) ~~"
    echo
  else
    echo "# ^ done ( \`${cmd[@]}\` )."
    echo
  fi
done
