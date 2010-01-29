#!/bin/sh
# Loads settings for the specified db
PATH=/bin:/usr/bin:$HOME/bin:${0%/*}

DUMP_TABLES=0

CONFIG_ROOT='./.db'

args=$*
IFS='   
='
while [ -n "$1" ]; do
    case "$1" in
        -d|-db|--database) db=$2; shift ;;
        -*) ;;
        *) 
            db=$1
    esac
    shift
done

if [ -z $db ]; then
    if [ -e $CONFIG_ROOT/default ]; then
        db=$(cat $CONFIG_ROOT/default);
    fi
fi
if [ -e $CONFIG_ROOT/settings ]; then
    SETTINGS=$CONFIG_ROOT/settings;
    if ! . $SETTINGS; then
        ERROR=$SETTINGS;
    fi
fi
if [ -e $CONFIG_ROOT/$db.settings ]; then
    SETTINGS=$CONFIG_ROOT/$db.settings;
    if ! . $SETTINGS; then
        ERROR=$SETTINGS;
    fi
fi

set -- $args >/dev/null
while [ -n "$1" ]; do
    case "$1" in
        -d|-db|--database) shift ;;
        -p|-pw|--password) PASSWORD=$2; shift ;;
        -f|--force) FORCE=0 ;;
        -i|--interactive) unset FORCE ;;
        --dump) DUMP_TABLES=0 ;;
        --no-dump) unset DUMP_TABLES ;;
        -r|--root) root=$2; shift ;;
    esac
    shift
done
set -- $args >/dev/null

root=${root-'.'}
patchlist=$db.list;

if [ ! $DB_DONT_COMPLAIN ]; then
    if [ $ERROR ]; then
        echo "db: error while loading '$ERROR'"
    fi
    if [ -z $db ]; then
        echo "db: no database specified and there is no default" 1>&2;
    fi
    if [ ! -e $CONFIG_ROOT/$db.settings ]; then
        echo "db: $CONFIG_ROOT/$db.settings does not exist" 1>&2; 
        exit 1
    fi
    if [ ! -e $patchlist ]; then
        echo "db: $patchlist not found" 1>&2
        exit 1
    fi
fi
