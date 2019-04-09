cite 'about-alias'
about-alias 'common git abbreviations'

# Aliases
alias g='git'
alias gcl='g clone'
alias ga='g add'
alias gai='ga --interactive'
alias gap='ga --patch' # see `grstp` counterpart.
alias gau='ga --update'

alias gf='g fetch'

#alias gall='git add .'
#alias gus='git reset HEAD'
#alias gm="git merge"
#alias get='git'
#alias gst='git status'
alias gs='g status'
alias gss='gs -s'
alias gs.='gs .'
alias gsp='gs --porcelain'
alias gsu='gs -uno'
#alias gl='git pull'
alias gpr='g pull --rebase'
alias gpp='g pull && g push'
alias gup='g fetch && g rebase -i'
alias gp='g push'
alias gpo='gp origin'
alias gpfo='gp -f origin'

alias gpuffo='g pull --ff-only'

alias gpu='g pull'
alias gpur='gpu --rebase'

alias gc='g commit -v'
alias gca='gc -a'
alias gci='g commit --interactive'
alias gcx='gc --amend -p'
#alias gcm='gc -v -m'
alias gcm='gc --amend'

alias gb='g branch'
alias gba='gb -a'
alias gbv='gb -vv'
# Remote tracking branch :
alias gbr='g rev-parse --abbrev-ref --symbolic-full-name @{u}'
alias gbn='g rev-parse --abbrev-ref --symbolic-full-name HEAD'


alias gco='g checkout'
alias gcp='g cherry-pick'
#alias gexport='git archive --format zip --output'
#alias gdel='git branch -D'
alias gmu='g fetch origin -v; g fetch upstream -v; g merge upstream/master'

alias gd='g diff --patience'
alias gdc='gd --cached'
alias gdr='gd `gbr`...'
alias gdrr='gd ...`gbr`'
alias gdv='g diff -w "$@" | vim -R -'

alias gds='gd origin/staging...'
alias gdsr='gd ...origin/staging'
alias gdd='gd origin/develop...'
alias gddr='gd ...origin/develop'
alias gdm='gd origin/master...'
alias gdmr='gd ...origin/master'

alias gl='g log --graph --stat --summary --decorate --source --abbrev-commit'
alias gll='g log --graph --pretty=oneline --abbrev-commit'
alias gl1='g log --oneline --graph --decorate --source'
alias gl11='gl1 -1'
alias glast='gl -1'
alias g1='gl -1'
alias gg="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gga="git log --pretty=format:'%Cblue%ad%Creset - %Cred%h%Creset - %an - %s %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=iso --date-order"
alias ggm='gg `git merge-base HEAD origin/master`...'
alias ggs='gg `git merge-base HEAD origin/staging`...'
alias ggd='gg `git merge-base HEAD origin/develop`...'
alias ggg="gg -3"
alias gsl="g shortlog -sn"
alias gw="g whatchanged"
alias gcount='g shortlog -sn'

alias gdhf='gd HEAD..FETCH_HEAD'
alias gdmh='gd MERGE_HEAD..'
alias gdhm='gd ..MERGE_HEAD'
alias gdho='gd ...ORIG_HEAD'
alias gdoh='gd ORIG_HEAD...'
alias glhf='gl HEAD..FETCH_HEAD'

alias glr='gl `gbr`...'
alias glrr='gl ...`gbr`'

# From http://blogs.atlassian.com/2014/10/advanced-git-aliases/
# Show commits since last pull
alias gnew="git log HEAD@{1}..HEAD@{0}"
# Add uncommitted and unstaged changes to the last commit
alias gcaa="git commit -a --amend -C HEAD"

alias gcf='g cat-file -p'
alias gls='g ls-files'

alias gm='g submodule'

alias gmt='g mergetool'

alias gr='g remote'
alias gru='gr update'
alias grv='gr -v'
alias glsr='g ls-remote'

alias grst='g reset'
alias grstp='g reset --patch' # see `gap` counterpart.

# TODO: alias or function for gsb HEAD with the remote, e.g. would be equiv. to e.g.:
#       gsb master origin/master
#       gsb live origin/live
#       gsb HEAD master ?
alias gsb='g show-branch'
alias gsbh='gsb --current'
alias gsbr='gsbh `gbr`'
alias gsh='g show'
alias gshr='gsh `gbr`'
alias gsbho='gsbh ORIG_HEAD'

# Compare wrt. Git/Flow-like branches
alias gsbm='gsbh origin/master'
alias gsbd='gsbh origin/develop'
alias gsbs='gsbh origin/staging'
alias gsbo='gsbh origin/master origin/staging origin/develop'

alias  gfsbr='gf && gsbr'

# Compare branch with its upstream tracking branch,
# i.e. git show branch develop develop@{u}
function gsbu() {
  gsb $1 "$1@{u}"
}

alias gt='g tag'

alias gst='g stash'
alias gstp='g stash push --patch'
alias gstl='gst list'
alias gsts='gst show'

if false; then
if [ -z "$EDITOR" ]; then
    case $OSTYPE in
      linux*)
        alias gd='git diff | vim -R -'
        ;;
      darwin*)
        alias gd='git diff | mate'
        ;;
      *)
        alias gd='git diff'
        ;;
    esac
else
    alias gd="git diff | $EDITOR"
fi
fi

