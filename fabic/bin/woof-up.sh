#!/bin/bash

wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/fabic.conf &&
	sleep 1.5 &&
	dhclient -i wlan0 -v

echo retv=$?
