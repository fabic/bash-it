# custom/10_aliases.bash @ https://github.com/fabic/bash-it
#
# F.2011-08-16 : Some custom miscellaneous aliases...

if [ `uname -s` != 'Darwin'  ]; then
    alias ls='ls --color=auto'
fi

# Get rid of that minimalist Vim we often find here and there...
alias vi=vim

# Replace current bash process with a new one.
alias ebl='exec bash -l'

# Ch.dir to my playground :
alias pg='cd -P ~/dev/pg && ebl'

# Go to Sublime Text config. dir.
alias stc='cd ~/.config/sublime-text-3 && exec bash -l'

# Sudo (and replace current process).
alias esu='exec sudo su -'


# fixme
alias fu='/sbin/fuser -v'
alias lsof='/usr/sbin/lsof'

alias papache='( httpd_pids=`pgrep -u $USER,apache,root httpd` ; [ ! "$httpd_pids" ] || ps -H u -p $httpd_pids )'

# Screen :
alias sls='screen -ls'
alias sr='screen -r'
alias sR='screen -R'

# Sublime Text
alias st='sublime_text.sh'
alias sta='st -a'
alias stn='st -n'
alias stw='st -w'

# “ Where is ” == which ...
#alias wi='type -p'
# ^ We now have a `w` function that does this and more
#   see `custom/01_functions.bash`
# ^ Now using `wi` for another "what is..."

# For your bin/s ripgrep wrapper script.
[ `type -t s` == "alias" ] && unalias s

if type -p fzf >/dev/null;
then
  [ `type -t z` == "alias" ] && unalias z
  alias z='fzf-tmux -m --preview="head -$LINES {}"'

  [ "`type -t fe`" == "function" ] && unset fe

  # Borrowed from ../plugins/available/fzf.plugin.bash
  zv() {
    about "Open the selected file in the default editor"
    group "fzf"
    param "1: Search term"
    example "fe foo"

    local IFS=$'\n'
    local files
    local indir=""

    # First arg. may be a dir. where to ch.dir. into
    # before searching.
    if [ $# -gt 0 ]; then
      if [ -d "$1" ]; then
        indir="$1"
        shift
      fi
    fi

    [ -n "$indir" ] && pushd "$indir"

    files=( $(fzf-tmux --query="$1" --multi --select-1 --exit-0 --preview='head -$LINES {}') )
    [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"

    [ -n "$indir" ] && popd
  }

fi
