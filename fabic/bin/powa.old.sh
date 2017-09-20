#!/bin/sh

batt () 
{ 
    local -a a=( `cat /proc/acpi/battery/BAT1/state |awk '{ print $3 }'` )
	local remcap=${a[3]}
	local rate=${a[2]}
	local t=$( echo "scale=2; $remcap/$rate" | bc -l )
	echo $t
}

cat /proc/acpi/battery/BAT1/state 

remtime=`batt`

echo -e "\n\nRemaining time: $remtime Hrs\n"

