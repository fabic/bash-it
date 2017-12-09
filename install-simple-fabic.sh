#!/bin/bash
#
# FABIC/2017-12-09
#

BASH_IT="$(cd "$(dirname "$0")" && pwd)"
BASH_IT="${BASH_IT#$HOME}"
BASH_IT="${BASH_IT##/}"

cd ~ || exit 1

ln -sfnvb "$BASH_IT/dot_bash_profile" ~/.bash_profile &&
ln -sfnvb "$BASH_IT/dot_bashrc"       ~/.bashrc &&
ln -sfnvb "$BASH_IT/dot_screenrc"     ~/.screenrc &&
ln -sfnvb "$BASH_IT/fabic/tmux.conf"  ~/.tmux.conf &&
ln -snv   "$BASH_IT/fabic/bin/"       ~/bin

if [ ! -d ~/.ssh ]; then
  echo "Creating ~/.ssh/"
  install -v -d -m0700 ~/.ssh
fi

ln -sfnvb "../$BASH_IT/fabic/dot_ssh_config" ~/.ssh/config

echo "$0 : DONE."

ln -sfnvb "../$BASH_IT/fabic/dot_config_sublime-text-3/" ~/.config/sublime-text-3

echo
echo "Your Vim conf. is at fabic/dude.vim/"
echo " \`-> Run fabic/dude.vim/re-install.sh if you will."
echo
echo "Run fabic/powerline-fonts/install.sh for some cool fonts (and Vim status bar enhancements)."
echo

