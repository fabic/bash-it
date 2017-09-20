#!/bin/sh

watch -n5 "( grep -E '^(processor|cpu MHz|model name|$)' /proc/cpuinfo ; free -m ; echo ; ps u -H --sid $( ps --no-headers -j --pid `pgrep "make"` | awk '{print $2, " ", $3}' | tsort | tail -n1 ) )"

