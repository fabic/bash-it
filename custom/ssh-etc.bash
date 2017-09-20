# custom/ssh-etc.sh
#
# @since 2015-10-01
# @author fabic.net

## List files / directory contents and output a line for
# the SCP <host>:<path> ... command.
#
# Ex.: lcp *
function lcp() {
    local arg
	for arg in "$@"; do
        echo $(hostname):$(ls -1d `pwd`/"$arg")
    done
}

# vim: et ts=4 sts=4 sw=4
