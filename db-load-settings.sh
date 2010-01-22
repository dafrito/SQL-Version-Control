#!/bin/sh
# Updates a database by running patches
PATH=/bin:/usr/bin:$HOME/bin:${0%/*}

FORCE=1

function load_settings {
    if [ ! -e $1 ]; then
        echo "$0: $1 does not exist" 1>&2; exit 1
    fi;
    if ! . $1; then
        exit 1
    fi
    SETTINGS=$1; 
}

args=$*
IFS='   
='
while [ -n "$1" ]; do
    case "$1" in
        -s|--settings) SETTINGS=$2; shift ;;
        -*) ;;
        *) 
            if [ -e $1 ]; then
                SETTINGS=$1
            fi
    esac
    shift
done
if [ -e ./db-settings ]; then
    load_settings ./db-settings
fi;
if [ -n "$DATABASE" ] && [ -e $DATABASE.db-settings ]; then
    load_settings ./$DATABASE.db-settings
fi
set $args >/dev/null
while [ -n "$1" ]; do
    case "$1" in
        -d|-db|--database) DATABASE=$2; shift ;;
        -s|--settings) 
            load_settings $2
            shift ;;
        -p|-pw|--password) PASSWORD=$2; shift ;;
        -f|--force) FORCE=0 ;;
        -i|--interactive) FORCE=1 ;;
        -l|--log) LOG=$2; shift ;;
        -*) echo "$0: Unknown argument $1" 1>&2; exit 1 ;;
        *) 
            if [ -e $1 ]; then
                load_settings $1
            else
                DATABASE=$1;
            fi
    esac
    shift
done
set $args >/dev/null
PATCH_ROOT=./patches

db=$DATABASE
root=$PATCH_ROOT
if [ -e $db.patchlist ]; then
    patchlist=$db.patchlist;
else
    patchlist=patchlist
fi

if [ "${db_utils_DONT_VERIFY}" != 0 ]; then
    echo ${SETTINGS?"db-settings not found. Set with -s, --settings, or run $0 from a dir that contains db-settings"} >/dev/null
    echo ${DATABASE?"$0: DATABASE not set. Set with -d, -db, --database, or specify in db-settings"} >/dev/null
    echo ${LOG='./db-$db.log'} >/dev/null
    if [ ! -e $patchlist ]; then
        echo "$0: $patchlist not found" 1>&2
        exit 1
    fi
fi
