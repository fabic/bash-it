#!/bin/bash
#
# F/2018-05-13
#
# Search for those log files you're typically interesed in,
# and tail follow these. Additionnal arguments may be log file names.
#

# TODO/?: `locate -b -r '\(\.\|_\)log$' | xargs -r ls -ldtr` instead of find ?
# TODO/?: monitor remote files too? like e.g. your vps stuff ?
#         `~> DON'T: JUST DO:
#             $ ( monitor-logs.sh & ssh vps.fabic.net monitor-logs.sh ) | ccze -A
# TODO: Find out how to cope with log rotation ?? like kill the tail process every one in a while ?

# Find out the normal user name, i.e. /me: fabi.
user="$( [[ $EUID -ne 0 ]] && whoami || echo "${SUDO_USER:-dude}" )"

# Get user home dir. (note: `getent` is Linux specific though -_-).
user_home="$(getent passwd "$user" | cut -f6 -d:)"

# For filtering out "old" files.
mtime=10

# For `tail -nX`
nlines_start=1

echo "+-- $0 $@"
echo "| \$user = $user"
echo "| \$user_home = $user_home"
echo "| \$mtime = $mtime"
echo "| \$nlines_start = $nlines_start"

searchdirs=(
    /var/log/httpd/
    /var/log/apache2/
    #/var/log/samba/
    # ^ Samba produces too many per-machine log files.
    /var/log/elasticsearch/
    #~$user/dev/*/tmp/
    # ^ Bash won't perform tild expansion here.
    #   (see https://stackoverflow.com/a/28208292)
    $user_home/dev/*/tmp/
    $user_home/dev/*/storage/logs/
    $user_home/dev/*/app/logs/
    $user_home/dev/*/var/log/
  )

# Symfony
[ -d var/log ] &&
  searchdirs=( "${searchdirs[@]}" "$PWD/var/log/" )

# Laravel
[ -d storage/logs ] &&
  searchdirs=( "${searchdirs[@]}" "$PWD/storage/logs/" )

# Find log files in those search dirs., keep the most recent ones.
logfiles=( /var/log/samba/?mbd.log
           /var/log/fail2ban.log
           /var/log/fpm-php.www.log
          )
           #"$(find ~/dev/ -maxdepth 5 -type f -name httpd-access.log -o -name httpd-errors.log)"

# Identify directories from files from cli args.
while [ $# -gt 0 ]; do
  arg="$1"
  shift
  [ -d "$arg" ] &&
    searchdirs=("${searchdirs[@]}" "$arg") ||
      logfiles=("${logfiles[@]}" "$arg")
done

# Filter out directories we can't read.
for i in ${!searchdirs[@]}; do
  if [[ ! -r ${searchdirs[$i]} ]]; then
    echo "| Skipping dir. '${searchdirs[$i]}' (doesn't exist / not readable)"
    unset 'searchdirs[i]'
  else
    echo "| Will search dir. '${searchdirs[$i]}'"
  fi
done

#echo "| Will search directories: ${searchdirs[@]}"

# Find log files in those search dirs., keep the most recent ones.
logfiles=( "${logfiles[@]}"
           $(find "${searchdirs[@]}" -type f -iname '*log' -mtime -$mtime)
          )

# Discard files we can't read / do not exist.
for i in ${!logfiles[@]}; do
  if [[ ! -r ${logfiles[$i]} ]]; then
    echo "| Skipping '${logfiles[$i]}' (doesn't exist / not readable)"
    unset 'logfiles[i]'
  else
    echo "| Including '${logfiles[$i]}'"
  fi
done

echo "+-"
echo "| Will tail follow these log files :"
  for log in ${logfiles[@]}; do
    echo "| - $log"
  done
echo "+-"

cmd=( tail -n$nlines_start -f "${logfiles[@]}" )

echo "| NOTE: We're launching \`journalctl -b -f\` too here (!)"

if [ ! -p /dev/stdout ] && type -p ccze >/dev/null ; then
  echo "| Great: found CCZE, piping output through it."
  echo "+--"
  echo
  ( ${cmd[@]} & journalctl -b -f ) | ccze -A
elif [ -p /dev/stdout ]; then
  echo "| Note: /dev/stdout is a pipe (FYI)"
  ( ${cmd[@]} & journalctl -b -f )
else
  ( ${cmd[@]} & journalctl -b -f )
fi

# NOTE: this is "stupid" actually: tail hardly ever exits "normaly" (you hit Ctlr-C).

retv=$?

echo
echo "+-"
echo "| Done, command was :"
echo "| ${cmd[@]}"
echo "+-- $0 $@"
echo

exit $retv

