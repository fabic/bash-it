#!/bin/bash
#
# Got that script from:
#
#   https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
#
# F/2018-04-18

composer_setup_php="composer-setup.php"

# We want to leave the installer script there in case user provided no arguments.
[ $# -gt 0 ] && shall_remove_installer_script=1 || shall_remove_installer_script=0

echo "+-- $0 $@"
echo "|"

echo "| Fetching installer signature."
EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
echo "| \` got: $EXPECTED_SIGNATURE"

echo "| Fetching composer-setup.php script."
php -r "copy('https://getcomposer.org/installer', '$composer_setup_php');"

if [ -s "composer_setup_php" ]; then
  echo "| OUCH! \` File '$composer_setup_php' either does not exit or is empty."
  exit 2
fi

echo "| Computing '$composer_setup_php' SHA384 signature."
ACTUAL_SIGNATURE="$(php -r "echo hash_file('SHA384', 'composer-setup.php');")"
echo "| \` got: $ACTUAL_SIGNATURE"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo "| ERROR: Invalid installer signature !"
    >&2 echo "|        \` expected: $EXPECTED_SIGNATURE"
    >&2 echo "|        \`      got: $ACTUAL_SIGNATURE"
    >&2 echo "|        \` Removing dubious file '$composer_setup_php'."
    rm -v composer-setup.php
    exit 1
fi

cmd=( php composer-setup.php "$@" )

echo "| Running :"
echo "|   ${cmd[@]}"
echo "+-"
echo

"${cmd[@]}"

RESULT=$?

if [ $RESULT -ne 0 ]; then
  echo
  >&2 echo "| ERROR: Non-zero exit status: $RESULT from \`${cmd[@]}\`"
  echo
  exit $RESULT
fi

if [ $shall_remove_installer_script -gt 0 ]; then
  rm -v composer-setup.php &&
    echo "| INFO: Removed temporary $composer_setup_php file."
else
  echo "| INFO: You provided no arguments for the installer script '$composer_setup_php',"
  echo "|       hence we're not removing it (in case you want to play with it)."
fi

echo "|"
echo "+-- $0 $@"
echo

exit $RESULT
