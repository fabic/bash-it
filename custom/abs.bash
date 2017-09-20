# https://github.com/fabic/bash-it/tree/master/custom/abs.sh

## @since 2016-07-03
## @author fabi@fabic.net
function abs() {
    if [ $# -eq 0 ]; then
        echo "Bash function $0 : gives absolute paths of arguments."
        echo
        echo "Usage:"
        echo "  $0 <file1> <file2> <dir1> <dir2> ..."
        echo
        echo "Examples :"
        echo "  $0 . .. ../.. ../lib ../include/header.h"
        return 1
    fi

    while [ $# -gt 0 ];
    do
        file="$1"
        shift

        dn="$( dirname "$file" )"
        bn="$( basename "$file" )"

        if [ ! -d "$file" ];
        then
            there="$( cd "$dn" && pwd )"
            echo "$there/$bn"
        else # it's already a directory.
            there=$( cd "$file" && pwd )
            echo "$there"
        fi
    done
}

# vi: et ts=4 sts=4 sw=4
