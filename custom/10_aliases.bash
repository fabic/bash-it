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
alias st='sublime_text'
alias sta='st -a'
alias stn='st -n'
alias stw='st -w'

# “ Where is ” == which ...
alias wi='type -p'
