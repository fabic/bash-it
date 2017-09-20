
## Arguments: <target_dir/> <command...>
## Recurse into the given target dir. ($1) and execute
## a command into it.
## Ex.: recurs_apply_into Downloads/ ls -l
## FC.2015-08-28
function recurs_apply_into() {
    local target_dir="$1"
    shift
    local cmd="$*"
    local cwd="$PWD"
    local retv=127

    if ! cd "$target_dir" ; then
        echo "WARNING: could not 'cd \"$target_dir\""
        return 127
    fi

    echo "# Exec. '$cmd' into \"`pwd`\" :"

    sh -c $cmd
    #( $cmd )

    retv=$?

    find -type d -not -name . |
    while read subdir; do
        recurs_apply_into "$subdir" $cmd
    done

    cd "$cwd"
}
