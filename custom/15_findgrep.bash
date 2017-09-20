# custom/15_findgrep.bash

# cgrep() : utility func. for grep-ing through C codebases.
# fabic 2015-11-30
function cgrep() {
    find -type f -name '*.[chsS]' -print0 | xargs -0r grep --color=auto "$@"

}
