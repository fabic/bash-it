#!/bin/bash
#
# 2018-09-19

dot_env=""

if [ $# -gt 0 ]; then
  if [ -f "$1" ]; then
    rewt="$(cd `dirname "$1"` && pwd)"
    dot_env="$(basename "$1")"
  else
    rewt="$(cd "$1" && pwd)"
    dot_env=".env"
  fi
else
  rewt="$(cd `dirname "$0"`/.. && pwd)"
  dot_env=".env"
fi

cd "$rewt" || (echo "$0: failed to ch. dir. into '$rewt'"; false) || exit 127

[ -f "$dot_env" ] || (echo "| ERROR: Ain't no file '$dot_env'"; false) || exit 125

echo "+-- $0 $@"
echo "| Working in dir. '$PWD'"

# Source .env file
[ -r .env ] || (echo "$0: ERROR: Ain't readable .env file '$dot_env' at '$PWD'"; false) || exit 125
source "$dot_env"

# Extract connection details from the database uri.
dbuser="${DATABASE_URL##mysql://}"
dbuser="${dbuser%%:*}"

dbpass="${DATABASE_URL##mysql://$dbuser:}"
dbpass="${dbpass%%@*}"

dbhost="${DATABASE_URL##*@}"
dbhost="${dbhost%%/*}"

dbport="${dbhost##*:}"
dbport="${dbport:-3306}"

dbhost="${dbhost%%:*}"

dbname="${DATABASE_URL##*/}"

echo "| DATABASE_URL = $DATABASE_URL"
echo "| \`~> dbhost = $dbhost"
echo "| \`~> dbport = $dbport"
echo "| \`~> dbuser = $dbuser"
echo "| \`~> dbpass = $dbpass"

dumpcmd=( mysqldump --single-transaction -u "$dbuser" --password="$dbpass" --host "$dbhost" --port "$dbport" "$dbname" )

if [ ! -z "$2" ] && [ -d "$2" ] && [ -w "$2" ]; then
  dump_to_file="${2}/$dbname.mysqldump.$dbhost.$(date -u '+%F %H%M%S %Z' | tr ': ' '._').sql.gz"
else
  dump_to_file="${2:-./}$dbname.mysqldump.$dbhost.$(date -u '+%F %H%M%S %Z' | tr ': ' '._').sql.gz"
fi

if [ -z "$dump_to_file" ]; then
  echo "| Will now execute command:"
  echo "|   $ ${dumpcmd[@]}"
  "${dumpcmd[@]}"
else
  echo "| Output file: $dump_to_file"
  echo "| Will now execute command:"
  echo "|   $ ${dumpcmd[@]} | gzip -cv > '$dump_to_file' "
  "${dumpcmd[@]}" | gzip -cv > "$dump_to_file"
fi

retv=$?

if [ $retv -gt 0 ]; then
  echo "| ERROR: Got a non-zero exit status: $retv"
  exit $retv
elif [ ! -z "$dump_to_file" ]; then
  ls -lh "$dump_to_file"
fi

echo "+-- $0 $@ : END"

