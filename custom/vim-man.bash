#
# Read man pages through Vim, thanks to the SuperMan plugin :
#
# http://vimawesome.com/plugin/vim-superman-superman
#

vman() {
  vim -c "SuperMan $*"

  if [ "$?" != "0" ]; then
    echo "No manual entry for $*"
  fi
}

# Have tab completion.
complete -o default -o nospace -F _man vman

