#!/bin/bash
#
# F/2018-09-11
#
# Turns on/off your external DELL monitor (connected to that new laptop of yours).

do="${1:-on}"

b='.95'
gamma='1.0:1.0:1.0'

if [ "$do" == "on" ]; then
  xrandr -v --output HDMI-0 --left-of DP-0 --mode 1920x1200 --dpi 96 --primary
  xrandr -v --output DP-0 --mode 1920x1080 --dpi 96 --brightness $b --gamma $gamma
elif [ "$do" == "off" ]; then
  xrandr -v --output HDMI-0 --off
  xrandr -v --output DP-0 --mode 1920x1080 --primary --dpi 96 --brightness $b --gamma $gamma
else
  echo
  echo "$0: Unknown action '$do' (EXITING)"
  echo
  exit 127
fi

