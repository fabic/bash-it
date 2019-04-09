#!/bin/bash
#
# F/2018-06-10

iptables -N tmp
iptables -I INPUT 1 -i wlp4s0 -p tcp -j tmp

# Drop all incoming SSH connections on my Wifi interface.
iptables -A tmp -i wlp4s0 -p tcp --dport 22 -j DROP
