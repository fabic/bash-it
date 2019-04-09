#!/bin/bash
#
# F/2018-06-18

# Check current dir. is a Laravel project,
# or infer the project root from this script location.
[[ -f ./artisan && -d bootstrap/ && -d vendor/ ]] &&
  rewt="$(cd -P . && pwd)" ||
  rewt="$(cd `dirname "$0"`/.. && pwd)" # move out of ./bin/

echo
echo "+- Hello o/ ich bin $0"
echo "|"
echo

echo "| Ch. dir. to app. root: $rewt"
cd "$rewt" || exit 1

[ -e ./artisan ] || (echo "| ERROR: ./artisan script not found at `pwd`." ; false) || exit 2

[ -e bootstrap/compiled.php ] &&
  echo "| Found a \`bootstrap/compiled.php\`, now running \`./artisan clear-compiled\` so as to clean it." &&
  php artisan clear-compiled

cmds=( "config:clear"
       "cache:clear" )

phpbin=php
type -p nxphp &&
  echo "| (will use your \`nxphp\` wrapper script)" &&
  phpbin=nxphp

for cmd in "${cmds[@]}"; do
  cmd=( php artisan ${cmd} )
  echo "| ${cmd[@]}"
  "${cmd[@]}"
  retv=$?
  [ $retv -gt 0 ] && echo "OUPS: Non-zero exit status: $retv"
done



