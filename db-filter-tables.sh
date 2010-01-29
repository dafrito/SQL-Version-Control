#!/bin/sh
# Updates a database by running patches
PATH=/bin:/usr/bin:$HOME/bin:${0%/*}

if [ -s $CONFIG_ROOT/ignore ]; then
    grep -v -f $CONFIG_ROOT/ignore
else 
    cat; 
fi | if [ -s $CONFIG_ROOT/$db/ignore ]; then
    grep -v -f $CONFIG_ROOT/$db/ignore
else
    cat;
fi |
egrep -xv "Tables_in_$db" |
egrep -xv "patches" |
egrep -xv "patch_changelog" |
egrep -xv "patch_history" |
egrep '[^[:space:]]'
