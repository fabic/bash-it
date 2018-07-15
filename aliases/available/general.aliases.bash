cite about-alias
about-alias 'general aliases'

if ls --color -d . &> /dev/null
then
  alias ls="ls --color=auto"
elif ls -G -d . &> /dev/null
then
  alias ls='ls -G'        # Compact view, show colors
fi

# List directory contents
alias sl=ls

# FABIC: upstream 2017-01-30
#alias la='ls -AF'       # Compact view, show hidden
#alias ll='ls -al'
#alias l='ls -a'
#alias l1='ls -1'

# FABIC: ^ my changes...
# https://the.exa.website/
if type -p exa >/dev/null; then
  alias lls="`type -P ls`"
  alias ls='exa'
  alias l1='ls -1'
  alias lh='ls'
  alias ll='ls -lgHS -@ --git --time-style=long-iso --header'
  alias la='ll -a'
  alias latr='ll -ar --sort=modified'
  alias ltrh='ll -r --sort=modified'
else
  alias ls='ls -G'        # Compact view, show colors
  alias ll='ls -lF'
  alias la='ll -a'       # Compact view, show hidden
  alias l='ls -F'
  alias l1='l -1sh'
  alias lh='ll -h'
  alias latr='la -tr'
  alias ltrh='ll -trh'
fi

#alias cdp='cd -P'
# ^ FABIC 2017-11: Replace with a function.
alias cpi='cp -i'

# du "star" & sort
alias dus='du -hsc * | sort -h'

alias dateiso="date '+%Y-%m-%d_%H%M%S'"

alias _="sudo"

# Shortcuts to edit startup files
alias vbrc="vim ~/.bashrc"
alias vbpf="vim ~/.bash_profile"

# colored grep
# Need to check an existing file for a pattern that will be found to ensure
# that the check works when on an OS that supports the color option
if grep --color=auto "a" "${BASH_IT}/"*.md &> /dev/null
then
  alias grep='grep --color=auto'
  export GREP_COLOR='1;33'
fi

if which gshuf &> /dev/null
then
  alias shuf=gshuf
fi

alias c='clear'
alias k='clear'
alias cls='clear'

alias edit="$EDITOR"
alias pager="$PAGER"

alias q='exit'

alias irc="$IRC_CLIENT"

# Language aliases
alias rb='ruby'
alias py='python'
alias ipy='ipython'

# Pianobar can be found here: http://github.com/PromyLOPh/pianobar/

alias piano='pianobar'

alias ..='cd ..'         # Go up one directory
alias cd..='cd ..'       # Common misspelling for going up one directory
alias ...='cd ../..'     # Go up two directories
alias ....='cd ../../..' # Go up three directories
alias -- -='cd -'        # Go back

# Shell History
alias h='history'

# Tree
if [ ! -x "$(which tree 2>/dev/null)" ]
then
  alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
fi

# Directory
alias md='mkdir -p'
alias rd='rmdir'

# Common misspellings of bash-it
alias shit='bash-it'
alias batshit='bash-it'
alias bashit='bash-it'
alias batbsh='bash-it'
alias babsh='bash-it'
alias bash_it='bash-it'
alias bash_ti='bash-it'

# Additional bash-it aliases for help/show
alias bshsa='bash-it show aliases'
alias bshsc='bash-it show completions'
alias bshsp='bash-it show plugins'
alias bshha='bash-it help aliases'
alias bshhc='bash-it help completions'
alias bshhp='bash-it help plugins'
alias bshsch="bash-it search"
alias bshenp="bash-it enable plugin"
alias bshena="bash-it enable alias"
alias bshenc="bash-it enable completion"

# Shorten extract
alias xt="extract"

# sudo vim
alias svim="sudo vim"

# Display whatever file is regular file or folder
catt() {
  for i in "$@"; do
    if [ -d "$i" ]; then
      ls "$i"
    else
      cat "$i"
    fi
  done
}
