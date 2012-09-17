#!/bin/bash

# test/demo script for debug.rc

source debug.rc  # will need $EXECDIR/ in install-scripts

dbg_echo "ok cool" shell-level-$SHLVL $*
dbg_echo_v 2 "ok very cool" shell-level=$SHLVL $*

# DBG_* vars are exported by debug.rc
# so subshells get them automatically

if (( $SHLVL < 4 )) ; then
    sh mydbg.sh woohoo $*
fi
