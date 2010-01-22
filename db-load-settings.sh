#!/bin/sh
# Updates a database by running patches
PATH=/bin:/usr/bin:$HOME/bin:${0%/*}

FORCE=1

IFS='   
='
while [ -n "$1" ]; do
    case "$1" in
        -d|-db|--database) DATABASE=$2; shift ;;
        -s|--settings) SETTINGS=$2; shift ;;
        -p|-pw|--password) PASSWORD=$2; shift ;;
        -f|--force) FORCE=0 ;;
        -i|--interactive) FORCE=1 ;;
        -l|--log) LOG=$2; shift ;;
        -*) echo "$0: Unknown argument $1" 1>&2; exit 1 ;;
        *) 
            if [ -e $1 ]; then
                SETTINGS=$1
            else
                DATABASE=$1;
            fi
    esac
    shift
done

explicit_settings=$SETTINGS
if [ -e ./db-settings ]; then
    . ./db-settings
    SETTINGS=./db-settings
fi;
if [ -n "$DATABASE" ] && [ -e $DATABASE.db-settings ]; then
    . ./$DATABASE.db-settings
    SETTINGS=./$DATABASE.db-settings
fi
if [ -n "$explicit_settings" ]; then
    if [ -e "$explicit_settings" ]; then
        echo $explicit_settings
        . $explicit_settings
        SETTINGS=$explicit_seetings
    else
        echo "$0: Settings not found at $explicit_settings"
        exit 1
    fi
fi
unset explicit_settings
PATCH_ROOT=./patches

db=$DATABASE
root=$PATCH_ROOT
patchlist=patchlist

if [ "${db_utils_DONT_VERIFY}" != 0 ]; then
    echo ${SETTINGS?"db-settings not found. Set with -s, --settings, or run $0 from a dir that contains db-settings"} >/dev/null
    echo ${DATABASE?"$0: DATABASE not set. Set with -d, -db, --database, or specify in db-settings"} >/dev/null
    echo ${LOG='./db-$db.log'} >/dev/null
    if [ ! -e $patchlist ]; then
        echo "$0: $patchlist not found" 1>&2
        exit 1
    fi
fi
