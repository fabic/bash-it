#!/bin/bash
#
# FABIC/2017-12-14
#

echo "+- $0 $@"
echo "|"
echo "| Install Sublime Text __through ArchLinux's Pacman__"
echo "|"
echo "| See https://www.sublimetext.com/docs/3/linux_repositories.html"
echo

#if [ -d "~/.rvm" ]; then
#  echo "+--> ~/.rvm/ already exists, exiting now..."
#  exit 1
#fi

echo "| Fetching GPG key."
echo

# TODO: Check if key is already known ?
curl -O https://download.sublimetext.com/sublimehq-pub.gpg &&
  sudo pacman-key --add sublimehq-pub.gpg &&
    sudo pacman-key --lsign-key 8A8F901A &&
      rm sublimehq-pub.gpg

retv=$?

if [ $retv -gt 0 ]; then
  echo
  echo "+~~ ERROR ~~> Could _NOT_ fetch/install the GPG signature."
  echo
  exit $retv
fi

echo
echo "| Adding [sublime-text] section at the end of /etc/pacman.conf ( SUDO ! )."
echo

# TODO: Check if already modified.
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/dev/x86_64" | \
  sudo tee -a /etc/pacman.conf

retv=$?

if [ $retv -gt 0 ]; then
  echo
  echo "+~~ ERROR ~~> Something bad happened while attempting to modify /etc/pacman.conf"
  echo
  exit $retv
fi

echo
echo "| Installing ( \`pacman -Syu sublime-text\` )"
echo

sudo \
  pacman -Syu sublime-text

retv=$?

if [ $retv -gt 0 ]; then
  echo
  echo "+~~ ERROR ~~> Pacman command exited with non-zero status code: $retv"
  echo
fi

echo "+- $0 $@ : END."

exit $retv

