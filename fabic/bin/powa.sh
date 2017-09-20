#!/bin/bash


for k in /sys/devices/system/cpu/cpufreq/policy* ;
do
	echo "+-- ~ ~ ~ $k/ ~ ~ ~"

	for j in \
		cpuinfo_min_freq cpuinfo_cur_freq cpuinfo_max_freq \
		scaling_available_frequencies scaling_cur_freq \
		scaling_available_governors scaling_governor \
		scaling_driver scaling_min_freq scaling_max_freq \
		affected_cpus related_cpus bios_limit cpb \
		cpuinfo_transition_latency freqdomain_cpus \
		scaling_setspeed stats ;
	do
		echo "|  * $j : `cat $k/$j`"
	done

	echo "|"
done

read -p "Specify scaling governor : " -e -i "performance" scalg

for k in /sys/devices/system/cpu/cpufreq/policy*/scaling_governor;
do
	echo "Current value '$k' : `cat $k`";
	echo "$scalg" > $k;
	echo "Reading updated value '$k' : `cat $k`"
done
