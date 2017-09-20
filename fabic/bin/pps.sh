#

function pps() {
	if [ $# -lt 1 ]; then
		echo
		echo "Invoque \`ps' searching for the top-most parent so as to display its process hierarchy."
		echo
		echo "Usage: $0 <pgrep_arguments> [-- <ps_arguments>]"
		echo
		echo "Where <pgrep_arguments> is typically a process name / command line pattern"
		echo "And <ps_arguments> are arguments for \`ps'."
		echo
		echo "For example, this will display the top \`make' process and its descendants: $0 make"
		echo
		echo "For example, this will display the top \`make' process and its descendants: $0 make"
		echo
		echo
	fi

	# Original cmd line :
	#ps u -H --sid $( ps --no-headers -j --pid `pgrep "$@"` | awk '{print $2, " ", $3}' | tsort | tail -n1 );

	local -a pgrep_args
	local -a ps_args
	local pids

	# Consume arguments for pgrep until '--' or end is met :
	while [ $# -gt 0 -a "$1" != "--" ]; do
		pgrep_args=( "${pgrep_args[@]}" "$1" )
		shift
	done

	[ "$1" == "--" ] && shift

	# 'ps' arguments replace our default ones if provided :
	ps_args=${@:-u -H}

	pids="`pgrep "${pgrep_args[@]}"`"
	pids=`echo $pids | tr ' ' ','`

	#echo pid -- $pids --- "${pids// /,}" ; return

	ps ${ps_args[@]} --sid $( ps --no-headers -j --pid $pids | awk '{print $2, " ", $3}' | tsort | tail -n1 );
}

if [ "${BASH_SOURCE[0]}" == $0 ]; then
	pps "$@"
fi
