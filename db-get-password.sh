#!/bin/bash
# Retrieves a password and verifies a log-in to the specified db.
PATH=/bin:/usr/bin:$HOME/bin:${0%/*}

source db-library.sh

if [ -z "$PASSWORD" ]; then
    trap 'stty echo; echo; exit 1' INT TERM
    read -s -p"Password for '$db': " PASSWORD
    echo
fi

# A no-op just to make sure we can connect
sql "use $db"
