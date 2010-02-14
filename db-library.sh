#!/bin/bash
# Common library functions

function sql {
    mysql $db -u $user -p"$PASSWORD" -e"$*"
    [ ! $? ] && [ ! "$TOLERANT" ] && exit 2
}

function sql_raw {
    mysql $db -u $user -p"$PASSWORD" -e"$*"
    return $?
}


function log_with_status {
    log_status=$1
    shift
    [ -r $log ] || return 1
    echo "db: $BUILD: [$log_status] " $* >>$log
    return $?
}

function log {
    log_with_status "II" $*
}

function warn {
    log_with_status "WW" $*
    [ $STRICT ] && exit 1
}

function error {
    log_with_status "EE" $*
    echo $* 1>&2
    [ $TOLERANT ] || exit 1
}

function get_tables {
    sql "show tables"
}

function get_history {
    sql "select table_name,type,order_applied from patch_history"
}

function perform_hook {
    if [ ! "$2" ]; then
        perform_hook $1 $CONFIG_ROOT
        perform_hook $1 $BUILD_CONFIG_ROOT
    fi
    [ ! -e $2/$1.sh ] && return 0
    [ ! -r $2/$1.sh ] && error "$2/$1 hook exists, but is not readable"
    . $2/$1.sh || error "$2/$1 hook returned exit code: $?"
    return 0
}

