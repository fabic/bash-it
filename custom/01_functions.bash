# custom/01_functions.bash @ https://github.com/fabic/bash-it
#
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

# F.2014-09-16
function hey() {
	local count=${1:-1}
	local sound=${2:-snap}
	local file="~/${sound}.wav"
	[ ! -r "$file" ] && file=~/snap.wav
	for(( ; count>0 ; count-- )); do
		aplay $file 2> /dev/null
	done
}

# @see alias tree='find . -print | sed -e '\''s;[^/]*/;|____;g;s;____|; |;g'\'''
function ftree()
{
	local -a in_dirs
	in_dirs=( $1 ) ; shift
	find "${in_dirs[@]}" -type d ${@:+-o \( "$@" \)} |
		sort -df |
		sed -e 's@[^/]*/@|__@g;s@__|@ |@g'
		#cat
	return $?
}

# Ch.dir. to the directory specified as 1st argument, hence `cd -P ...`
# But: if target is a file, then ch.dir. into the containing directory.
# Also, if target is a symlink, then attempt to jump into the pointed to dir.
function cdp()
{
    if [ -L "$1" ]; then # BEWARE! RECURSION!
        cdp "$(readlink "$1")"
    elif [ ! -d "$1" ]; then
        cd -P "$(dirname "$1")"
    else
        cd -P "$1"
    fi
}
# vi: et ts=4 sts=4 sw=4
