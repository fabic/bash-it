# F.2011-08-24 : Sybase ASE stuff.
#
# See /opt/sybase/SYBASE.sh
#

export SYBASE=/opt/sybase
export SYBASE_OCS=OCS-15_0

# Hummm what was that thing about ?
#export SYBPLATFORM=linux

# Default Server alias :
export DSQUERY=SYBTEST

# PATH
[ -d "$SYBASE/$SYBASE_OCS/bin" ] && pathprepend "$SYBASE/$SYBASE_OCS/bin"

# LD_LIBRARY_PATH & LIB
[ -d "$SYBASE/$SYBASE_OCS/lib" ] \
    && pathprepend "$SYBASE/$SYBASE_OCS/lib" LD_LIBRARY_PATH \
    && pathprepend "$SYBASE/$SYBASE_OCS/lib" LIB

# INCLUDE
[ -d "$SYBASE/$SYBASE_OCS/include" ] && pathprepend "$SYBASE/$SYBASE_OCS/include" INCLUDE
