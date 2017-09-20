#!/bin/sh
#
# fcj.2013-12-28 from Run.
#

( date ; uptime ; ifconfig ) | curl -d - http://fabic.net/ping/`hostname -a`

