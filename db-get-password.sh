#!/bin/bash
# Retrieves a password and verifies a log-in to the specified db.
PATH=/bin:/usr/bin:$HOME/bin:${0%/*}

if [ ! $PASSWORD ]; then
    if [ -s $DB_CONFIG_ROOT/password ]; then
        PASSWORD=$(cat $DB_CONFIG_ROOT/password);
    elif [ -s $CONFIG_ROOT/password ]; then
        PASSWORD=$(cat $CONFIG_ROOT/password);
    fi
fi

if [ -z "$PASSWORD" ]; then
    trap 'stty echo; echo; exit 1' INT TERM
    read -s -p"Password for '$db': " PASSWORD
    echo
fi

if ! mysql $db -u "$user" -p$PASSWORD -e"use $db"; then
    exit 2
fi
