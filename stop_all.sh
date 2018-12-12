#!/bin/bash

set -ue
source ./_env.sh

function stop()
{
	local name="$1"
	local pid=`get_pid $1`
	if [ ! -z "$pid" ]; then
		kill $pid
	fi
	sleep 0.2
	pid=`get_pid $1`
	if [ ! -z "$pid" ]; then
		kill -9 $pid
	fi
}

echo "=> stop pd-server"
stop pd-server

echo "=> stop tikv-server-master"
stop tikv-server-master

echo "=> stop tikv-server-rngine"
stop tikv-server-rngine

echo "=> stop tidb"
stop tidb-server

echo "=> stop theflash"
stop theflash
