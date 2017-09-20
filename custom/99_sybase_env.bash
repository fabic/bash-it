# F.2011-08-24 : Sybase ASE stuff.
#
# See /opt/sybase/SYBASE.sh
#

#return
# ^ F.2014-08-12 : I'm making these stuff system-wide! See /etc/env.d/

SYBASE=${SYBASE:-/opt/sybase}
SYBASE_OCS=${SYBASE_OCS:-OCS-15_0}

# RETURN (don't proceed further) unless `isql` command exists :
[ -e "$SYBASE/$SYBASE_OCS/bin/isql" ] || return

# Hummm what was that thing about ?
#export SYBPLATFORM=linux

# Default Server alias :
DSQUERY=${DSQUERY:-SYBTEST}

# PATH
[ -d "$SYBASE/$SYBASE_OCS/bin" ] && pathprepend "$SYBASE/$SYBASE_OCS/bin"

# LD_LIBRARY_PATH & LIB
[ -d "$SYBASE/$SYBASE_OCS/lib" ] \
    && pathprepend "$SYBASE/$SYBASE_OCS/lib" LD_LIBRARY_PATH \
    && pathprepend "$SYBASE/$SYBASE_OCS/lib" LIB

# INCLUDE
[ -d "$SYBASE/$SYBASE_OCS/include" ] && pathprepend "$SYBASE/$SYBASE_OCS/include" INCLUDE

export SYBASE SYBASE_OCS DSQUERY
