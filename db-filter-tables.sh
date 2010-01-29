#!/bin/sh
# Updates a database by running patches
PATH=/bin:/usr/bin:$HOME/bin:${0%/*}

if [ -e $CONFIG_ROOT/$db.ignore ]; then
    fgrep -v $CONFIG_ROOT/$db.ignore |
    fgrep -v $CONFIG_ROOT/ignore
else
    egrep -xv "Tables_in_$db" |
    egrep -xv "patches" |
    egrep -xv "patch_changelog" |
    egrep -xv "patch_history"
fi | egrep '[^[:space:]]'
