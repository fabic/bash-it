# custom/06_git.bash (fabic's bash-it fork)
#
# F/2018-05-19
#
# See also ../plugins/enabled/git.plugin.bash


## git_clean_local_merged_branches [origin/staging|staging|master|...]
#
# Delete local branches that have been merged into (default:) origin/staging
# Performs a git fetch first if a remote could be inferred.
function git_clean_local_merged_branches() {
  # Got that one from Jef # jef.digital (2018/04) :
  #
  #   git branch --merged |
  #     grep -v "\*" |
  #     grep -Ev "(\*|master|develop|staging)" |
  #     xargs -n 1 git branch -d

  wrt=""
  remote=""
  branch=""

  if [ $# -gt 0 ]; then
    if [ $# -eq 1 ]; then
      wrt="$1"
    elif [ $# -eq 2 ]; then
      wrt="$1/$2"
    else
      echo "$0: incorrect number of arguments."
      return 127
    fi
  else
    wrt="origin/staging"
  fi

  # if wrt contains a '/' then extract the remote out of it.
  [ "${wrt//\//}" != "${wrt}" ] &&
    remote="${wrt%%/*}"
  branch="${wrt#${remote:+$remote/}}"

  echo "+--"
  echo "| wrt:    $wrt  (with regards to)"
  echo "| remote: $remote"
  echo "| branch: $branch"

  if [ -n "$remote" ]; then
    echo "+-"
    echo "| Fetching refs from remote: $remote"
    git fetch "$remote" -vp || (echo "+~~> ERROR: git fetch failed" && false) || return 1
  fi

  # if not specified, git branch --merged "compares" against HEAD.
  [ -z "$wrt" ] && read -p "| Ouch? \$wrt is not defined, continue ? (Ctrl-C to abort)"

  echo "+-"
  git branch --merged "${wrt}" |
    grep -Ev "(^\*|master|develop|staging)" | # xargs -n1 git branch -d
    while read branch; do
      #rtracking="$(g rev-parse --abbrev-ref --symbolic-full-name $branch@{upstream})"
      # ^ git rev-parse can't cope with branches that contain '/' it appears (2018-05).
      _remote="$(g config "branch.$branch.remote")"
      _remote_branch="$(g config "branch.$branch.merge")"
      _remote_branch="${_remote_branch##refs/heads/}"
      echo "| deleting local branch: $branch ${_remote:+-> $_remote/$_remote_branch}"
      git branch -d "$branch" || break
    done
  retv=$?

  [ $retv -gt 0 ] && echo "| WARNING: Non-zero exit status: $?  (somehow)"
  echo "+-"

  return $retv
}


