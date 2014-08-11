# F.2011-08-16 : From LFS (http://www.linuxfromscratch.org/blfs/view/stable/postlfs/profile.html)

# Functions to help us manage paths.  Second argument is the name of the
# path variable to be modified (default: PATH)
pathremove () {
        local IFS=':'
        local NEWPATH
        local DIR
        local PATHVARIABLE=${2:-PATH}
        for DIR in ${!PATHVARIABLE} ; do
                if [ "$DIR" != "$1" ] ; then
                  NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
                fi
        done
        export $PATHVARIABLE="$NEWPATH"
}

pathprepend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

pathappend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
}

# F.2011-11-22 : Vim in dir...
vin() {
    local dest="$1"
    pushd "$dest" &&
        shift &&
        vim "$@" &&
    popd
}

# Fcj.2014-03-04
function vimdiff_cycle()
{
        local filename=""
        local prev=""
        for filename in "$@";
        do
                if [ "x$prev" = "x" ]; then 
                        prev="$filename"
                        continue
                fi

                read -p "--- About to DIFF. $prev AGAINST $filename ; press any key to continue, or Ctrl-C to abort. ---"

                vimdiff "$prev" "$filename"

                prev="$filename"
        done
}

proxy_unset() {
    #local -a varlist=( HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY NO_PROXY )
    local -a varlist=( $(env | grep -io '^.\+_proxy=') )
    local var
    varlist=${varlist[*]%=}
    for var in ${varlist[*]}; do
        #echo $var ${!var}
        #continue
        if [ -v $var ]; then
            echo "unset $var (${!var})"
            unset -v $var
        fi
    done
}
