#!/usr/bin/env bash

if [ "$DEBUG" = "1" ]; then
    BUILDOPT="--debug"
    TRGDIR="./target/debug"
    set -x
else
    BUILDOPT=""
    TRGDIR="./target/release"
fi

REMOTE_HOST="${1:-192.168.123.4}"
export tooldir="/mnt/Tank/tools/asterctl"




cargo build $BUILDOPT
ssh truenas_admin@"${REMOTE_HOST}" "mkdir -p $tooldir"
rsync -a -v --progress --delete-after $TRGDIR/* Monitor*.json truenas_admin@"${REMOTE_HOST}":$tooldir
ssh truenas_admin@"${REMOTE_HOST}" "chmod +x $tooldir/asterctl && ls -la $tooldir/"
ssh truenas_admin@"${REMOTE_HOST}" "cd $tooldir; ./asterctl --demo --config Monitor3.json"
