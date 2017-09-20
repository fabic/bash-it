# https://github.com/fabic/bash-it/tree/master/custom/wdiff.sh

## wdiff() ~ diff with ~ diff the given file(s) against their counter-part from the specified target directory
##
## @since 2016-08-18
## @author fabi@fabic.net
function wdiff() {

    local Vim="vim"

    # Use gVim if running under X :
    [ ! -z "$DISPLAY" ] && Vim="gvim"

    if [ $# -eq 0 ]; then
        echo "Bash function $0 : run vimdiff..."
        echo
        echo "Usage:"
        echo "  $0 <target_compare_against_dir> <file1> [<file2> <dir1> <dir2> ...]"
        echo
        echo "Examples :"
        echo "  $0 . .. ../.. ../lib ../include/header.h"
        return 1
    fi

    there="$1"
    shift

    while [ $# -gt 0 ];
    do
        file="$1"
        shift

        if [ ! -e "$file" ]; then
            echo "SKIPPING non-existent local file '$file'"
            continue
        elif [ ! -e "$there/$file" ]; then
            echo "SKIPPING non-existent __\"other\"__ file '$there/$file'"
            continue
        fi

        "$Vim" -d "$there/$file" "$file"

        retv=$?

        if [ $retv -gt 0 ]; then
            echo "EXITING NOW due to non-zero exit status from Vim : $retv"
            break
        fi
    done

    echo "FINISHED"
}

# vi: et ts=4 sts=4 sw=4
