#!/bin/bash
#
# F/2018-06-30


echo "+-- $0 $@"
echo "|"
echo "| Meteor.js"
echo "|"
echo "| https://www.meteor.com/install"
echo "|"
echo "| Note: there's also an ArchLinux AUR package at :"
echo "|       https://aur.archlinux.org/packages/meteor-js/"
echo "|"

curl https://install.meteor.com/ | sh "$@"

RESULT=$?

if [ $RESULT -ne 0 ]; then
  echo
  >&2 echo "| ERROR: Non-zero exit status: $RESULT from \`${cmd[@]}\`"
  echo
  exit $RESULT
fi

echo "|"
echo "+-- $0 $@"
echo

exit $RESULT
