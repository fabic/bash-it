#!/bin/bash
#
# FABIC/2017-12-11

echo "+- $0 $@"
echo "|"
echo "| Install Ruby through RVM: Ruby Version Mgmt."
echo "|"
echo "| See http://rvm.io/rvm/install"
echo "| See https://wiki.archlinux.org/index.php/RVM"
echo

if [ -d "~/.rvm" ]; then
  echo "+--> ~/.rvm/ already exists, exiting now..."
  exit 1
fi

echo "| Fetching GPG keys."
echo

if ! gpg --keyserver hkp://keys.gnupg.net \
         --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB ;
then
  echo
  echo "| WARNING: Failed to import GPG keys, proceeding anyway..."
  echo
fi

echo
echo "| Running RVM install script."
echo

curl -sSL https://get.rvm.io | \
          bash -s stable --ignore-dotfiles --version latest --ruby --with-gems=""
retv=$?

if [ $retv -gt 0 ]; then
  echo
  echo "| WARNING: Bad exit status from RVM install script: $retv"
fi

echo "+- $0 $@ : END."

exit $retv

