# custom/99_completion.bash (fabic's bash-it)
#
# F/2018-05-19
#
# https://stackoverflow.com/a/15009611

__git_complete g __git_main

__git_complete ga  _git_add
__git_complete gc  _git_commit
__git_complete gb  _git_branch
__git_complete gco _git_checkout
__git_complete gcp _git_cherry_pick
__git_complete gd  _git_diff
__git_complete gf  _git_fetch
__git_complete gl  _git_log

__git_complete gsb  _git_show_branch
__git_complete gsbh _git_show_branch
__git_complete gsbm _git_show_branch
__git_complete gsbs _git_show_branch
__git_complete gsbo _git_show_branch

__git_complete gst _git_stash
__git_complete gm  _git_submodule
__git_complete gp  _git_push
__git_complete gpu _git_pull
__git_complete gr  _git_remote

