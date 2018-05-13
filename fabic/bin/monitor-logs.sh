#!/bin/bash
#
# F/2018-05-13
#
# Search for those log files you're typically interesed in,
# and tail follow these. Additionnal arguments may be log file names.
#

# TODO/?: `locate -b -r '\(\.\|_\)log$' | xargs -r ls -ldtr` instead of find ?

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
    $user_home/dev/*/var/logs/
  )

#echo "DEBUG: ${searchdirs[@]}" ; exit 1

# Find log files in those search dirs., keep the most recent ones.
logfiles=( /var/log/samba/?mbd.log
           /var/log/fail2ban.log
           "$(find "${searchdirs[@]}" -iname '*log' -mtime -$mtime)"
           "$@" )

# Discard files we can't read / do not exist.
for i in ${!logfiles[@]}; do
  if [[ ! -r ${logfiles[$i]} ]]; then
    echo "| Skipping '${logfiles[$i]}' (doesn't exist / not readable)"
    unset 'logfiles[i]'
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

