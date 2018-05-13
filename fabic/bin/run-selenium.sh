#!/bin/bash
#
# F/2018-05-09

# TODO: also test for presence of those 'chromedriver' & 'geckodriver' files.
# FIXME: We're sticking with Selenium v2.x here (for Behat/Mink ain't compatible with v3.x at this time, 2018-05).

here="$(cd `dirname "$0"` && pwd)"

seleniums=( $(ls -1 "$here"/selenium-server-standalone-2.*.jar | sort -Vr) )
selenium="${seleniums[0]}"

echo "+-- $0 $@"
echo "| Found those Selenium .jar files :"
echo "| ${seleniums[@]}"
echo "|"
echo "| Will now run \`java -jar '$selenium' $@\`"
echo "|"
echo "+-"

time \
  java -jar "$selenium" "$@"

retv=$?

if [ $retv -gt 0 ]; then
  echo
  echo "+-"
  echo "| WARNING: Non-zero exit status: $retv"
  echo "+-- $0 $@"
  echo
fi

exit $retv
