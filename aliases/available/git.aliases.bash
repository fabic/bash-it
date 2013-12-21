cite 'about-alias'
about-alias 'common git abbreviations'

# Aliases
alias g='git'
alias gcl='g clone'
alias ga='g add'
alias gai='ga --interactive'
alias gap='ga --patch'
alias gau='ga --update'
#alias gall='git add .'
#alias gus='git reset HEAD'
#alias gm="git merge"
#alias get='git'
#alias gst='git status'
alias gs='g status'
alias gss='gs -s'
alias gsu='gs -uno'
alias gs.='gs .'
#alias gl='git pull'
alias gpr='g pull --rebase'
alias gpp='g pull && git push'
alias gup='g fetch && git rebase'
alias gp='g push'
alias gpo='gp origin'
alias gdv='g diff -w "$@" | vim -R -'

alias gc='g commit -v'
alias gca='gc -a'
alias gci='g commit --interactive'
#alias gcm='gc -v -m'
alias gcm='gc --amend'

alias gb='g branch'
alias gba='gb -a'
alias gbv='gb -v'

alias gco='g checkout'
alias gcp='g cherry-pick'
#alias gexport='git archive --format zip --output'
#alias gdel='git branch -D'
alias gmu='g fetch origin -v; g fetch upstream -v; g merge upstream/master'

alias gd='g diff --patience'
alias gdc='gd --cached'
alias gdhf='gd HEAD..FETCH_HEAD'

alias gl='g log --graph --stat --summary --decorate --source --abbrev-commit'
alias gll='g log --graph --pretty=oneline --abbrev-commit'
alias gl1='g log --oneline --graph --decorate --source'
alias glhf='gl HEAD..FETCH_HEAD'
alias gg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias ggs="gg --stat"
alias gsl="g shortlog -sn"
alias gw="g whatchanged"
alias gcount='g shortlog -sn'

alias gcf='g cat-file -p'
alias gls='g ls-files'

alias gm='g submodule'

alias gmt='g mergetool'

alias gr='g remote'
alias gru='gr update'
alias grv='gr -v'
alias glsr='g ls-remote'

# TODO: alias or function for gsb HEAD with the remote, e.g. would be equiv. to e.g.:
#       gsb master origin/master
#       gsb live origin/live
#       gsb HEAD master ?
alias gsb='g show-branch'
alias gsbh='gsb HEAD'
alias gsh='g show'
alias gt='g tag'


#if [ -z "$EDITOR" ]; then
#    case $OSTYPE in
#      linux*)
#        alias gd='git diff | vim -R -'
#        ;;
#      darwin*)
#        alias gd='git diff | mate'
#        ;;
#      *)
#        alias gd='git diff'
#        ;;
#    esac
#else
#    alias gd="git diff | $EDITOR"
#fi
