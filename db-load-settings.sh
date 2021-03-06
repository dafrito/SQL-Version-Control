#!/bin/bash
# Loads settings for the specified db
PATH=/bin:/usr/bin:$HOME/bin:${0%/*}

source db-library.sh;

DB_UTILS_ROOT=${0%/*}
CONFIG_ROOT='./.db'

function get_build_from_args {
    found=1;
    while [ -n "$1" ]; do
        case "$1" in
            -*) ;;
            *) 
                BUILD=$1
                found=0
        esac
        shift
    done
    return $found
}

function get_build_by_inference {
    old=$IFS
    IFS='
'
    set -- $(find $CONFIG_ROOT/* -maxdepth 0 -type d) >/dev/null
    IFS=$old
    case "$#" in
        1) 
            BUILD=${1##*/} 
            return 0
            ;;
        0) 
            ERROR="no database or patchlist found"
            return 1
            ;;
        *) 
            ERROR=$(echo "multiple lists found: " $*)
            return 1
            ;;
    esac
    # Should never get here.
    error "Unreachable point reached"
}

if [ ! "$BUILD" ]; then
    get_build_by_inference $*
    get_build_from_args $*
fi

function load_settings {
    if [ ! -s $1 ]; then
        return 0;
    fi
    if ! source $1; then
        error "$1 returned exit code: $?"
    fi
}

if [ ! "$DONT_LOAD_SETTINGS" ]; then
    saved_build=$BUILD
    load_settings $CONFIG_ROOT/settings
    load_settings $CONFIG_ROOT/settings.local
    if [ $saved_build ]; then
        BUILD=$saved_build
    fi
fi

if [ ! $TOLERANT ] && [ ! "$BUILD" ]; then
    error "No suitable build was found or provided"
fi

BUILD_CONFIG_ROOT="$CONFIG_ROOT/$BUILD"

if [ ! "$TEMP_ROOT" ]; then
    TEMP_ROOT="/tmp/db-utils/$BUILD-${0##*/}-$$"
    mkdir -p $TEMP_ROOT

    function cleanup {
        [ -e "$TEMP_ROOT" ] && rm -rf "$TEMP_ROOT"
    }
    trap cleanup EXIT
    trap 'stty echo; echo; cleanup; exit 1' INT TERM
fi

if [ ! "$DONT_LOAD_SETTINGS" ]; then
    load_settings $BUILD_CONFIG_ROOT/settings;
    load_settings $BUILD_CONFIG_ROOT/settings.local;
fi

function load_arguments {
    # Tab, space, newline, and equals
    old=$IFS
    IFS='   
    ='
    set -- $* >/dev/null
    IFS=$old
    while [ -n "$1" ]; do
        case "$1" in
            -db|--database) db=$2; shift ;; 
            -p|-pw|--password) PASSWORD=$2; shift ;;
            -f|--force) FORCE=0 ;;
            -i|--interactive) unset FORCE ;;
            --dump) dump=0 ;;
            --no-dump) unset dump;;
            -r|--root) root=$2; shift ;;
            -l|--log) log=$2; shift ;;
            -u|--user) user=$2; shift ;;
        esac
        shift
    done
}
load_arguments

if [ ! "$log" ]; then
    if [ -e "$BUILD_CONFIG_ROOT" ]; then
        log="$BUILD_CONFIG_ROOT/log"
    elif [ -e "$CONFIG_ROOT" ]; then
        log="$CONFIG_ROOT/log"
    fi;
fi
if [ $log ] || [ ! $TOLERANT ]; then
    log=$(readlink -f $log)
fi

root=${root-'.'}
user=${user-$USER}
db=${db-$BUILD}
patchlist=${patchlist-$BUILD.list}
if [ ! $TOLERANT ] && [ ! -e $patchlist ]; then
    error "$patchlist not found"
fi
