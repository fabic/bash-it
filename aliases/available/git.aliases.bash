cite 'about-alias'
about-alias 'common git abbreviations'

# Aliases
alias g='git'
#alias gcl='git clone'
#alias ga='git add'
#alias gall='git add .'
#alias gus='git reset HEAD'
#alias gm="git merge"
#alias get='git'
#alias gst='git status'
#alias gs='git status'
#alias gss='git status -s'
#alias gl='git pull'
#alias gpr='git pull --rebase'
#alias gpp='git pull && git push'
#alias gup='git fetch && git rebase'
#alias gp='git push'
#alias gpo='git push origin'
#alias gdv='git diff -w "$@" | vim -R -'
#alias gc='git commit -v'
#alias gca='git commit -v -a'
#alias gci='git commit --interactive'
#alias gb='git branch'
#alias gba='git branch -a'
#alias gcount='git shortlog -sn'
#alias gcp='git cherry-pick'
#alias gco='git checkout'
#alias gexport='git archive --format zip --output'
#alias gdel='git branch -D'
#alias gmu='git fetch origin -v; git fetch upstream -v; git merge upstream/master'
#alias gll='git log --graph --pretty=oneline --abbrev-commit'
#alias gg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
#alias ggs="gg --stat"
#alias gsl="git shortlog -sn"
#alias gw="git whatchanged"
#alias gcl='g clone'

alias ga='g add'
#alias gall='g add .'
alias gb='g branch'
#alias gba='g branch -a'
alias gc='g commit -v'
alias gca='gc -a'
alias gci='g commit --interactive'
alias gco='g checkout'
alias gcount='g shortlog -sn'
alias gcp='g cherry-pick'

alias gd='g diff --patience'
alias gdc='gd --cached'
alias gdhf='gd HEAD..FETCH_HEAD'
alias gdv='git diff -w "$@" | vim -R -'
#alias gc='git commit -v'
#alias gca='git commit -v -a'
#alias gcm='git commit -v -m'
#alias gci='git commit --interactive'
#alias gb='git branch'
#alias gba='git branch -a'
#alias gcount='git shortlog -sn'
#alias gcp='git cherry-pick'
#alias gco='git checkout'
#alias gexport='git archive --format zip --output'
#alias gdel='git branch -D'
#alias gmu='git fetch origin -v; git fetch upstream -v; git merge upstream/master'
#alias gll='git log --graph --pretty=oneline --abbrev-commit'
#alias gg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
#alias ggs="gg --stat"
#alias gsl="git shortlog -sn"
#alias gw="git whatchanged"
alias gw="g whatchanged"

alias gcf='g cat-file'
alias gls='g ls-files'

alias gl='g log --graph --stat --summary --decorate --source --abbrev-commit'
alias gll='g log --graph --pretty=oneline --abbrev-commit'
alias gl1='g log --oneline --graph --decorate --source'
alias glhf='gl HEAD..FETCH_HEAD'

alias gmt='g mergetool'

alias gr='g remote'
alias gru='g remote update'

alias gs='g status'
alias gss='gs -s'
alias gsu='gs -uno'
alias gs.='gs .'

# TODO: alias or function for gsb HEAD with the remote, e.g. would be equiv. to e.g.:
#       gsb master origin/master
#       gsb live origin/live
#       gsb HEAD master ?
alias gsb='g show-branch'
alias gsh='g show'
alias gt='g tag'


#alias get='git'
#alias gst='git status'
#alias gl='git pull'
#alias gup='git fetch && git rebase'
#alias gp='git push'
#alias gpo='git push origin'
#alias gexport='git archive --format zip --output'
#alias gdel='git branch -D'
#alias gmu='git fetch origin -v; git fetch upstream -v; git merge upstream/master'

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
