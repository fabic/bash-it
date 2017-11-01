#!/bin/bash
#
# FABIC/2017-10
#
# Basically sends me an e-mail (need this for being informed of command completion).

cat <<EOF | mail -s "Ok: $*" cadet.fabien@gmail.com
$*

Hi dude, this is host '`hostname -f`', now is `date`.

Cheers, bye ;-
EOF

