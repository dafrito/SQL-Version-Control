#!/bin/sh
# Loads settings for the specified db
PATH=/bin:/usr/bin:$HOME/bin:${0%/*}

CONFIG_ROOT='./.db'

function error {
    if [ $DB_DONT_COMPLAIN ]; then
        return;
    fi
    echo $* 1>&2
    exit 1
}

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
    if [ -s $CONFIG_ROOT/default ]; then
        db=$(cat $CONFIG_ROOT/default);
    fi
fi

if [ -z $db ]; then
    IFS='
'
    set -- $(find -name '*.list') >/dev/null
    case "$#" in
        1) db=${1%.*} ;;
        0) error "db: no database or patchlist found" ;;
        *) error "db: multiple lists found: " $* ;;
    esac
    set -- $args >/dev/null
fi

if [ -s $CONFIG_ROOT/settings ]; then
    SETTINGS=$CONFIG_ROOT/settings;
    if ! . $SETTINGS; then
        ERROR=$SETTINGS;
    fi
fi
if [ -s $CONFIG_ROOT/$db/settings ]; then
    SETTINGS=$CONFIG_ROOT/$db/settings;
    if ! . $SETTINGS; then
        ERROR=$SETTINGS;
    fi
fi

IFS='   
='
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
        -l|--log) log=$2; shift ;;
    esac
    shift
done
set -- $args >/dev/null

if [ -z $log ]; then
    if [ -e $CONFIG_ROOT ]; then
        if [ -e $CONFIG_ROOT/$db ]; then
            log=$CONFIG_ROOT/$db/log
        else
            log=$CONFIG_ROOT/log
        fi
    fi
fi
root=${root-'.'}
patchlist=$db.list;

if [ -z $db ]; then
    error "db: no database specified and there is no default";
fi
if [ ! -e $patchlist ]; then
    error "db: $patchlist not found"
fi
