#!/bin/sh
# Retrieves a password and verifies a log-in to the specified db.
PATH=/bin:/usr/bin:$HOME/bin:${0%/*}

. db-load-settings.sh >/dev/null

if [ -z "$PASSWORD" ]; then
    trap 'stty echo; echo; exit 1' INT TERM
    read -s -p'MySQL Password: ' PASSWORD
    echo
fi

if ! mysql $DATABASE -p$PASSWORD -e"use $DATABASE"; then
    exit 2
fi
