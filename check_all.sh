#!/bin/bash

set -ue
source ./_env.sh

function check()
{
	local name="$1"
	echo "=> $name"
	local pid=`get_pid $name`
	if [ -z "$pid" ]; then
		echo "   not running"
	else
		echo "   `get_pid $name`"
	fi
}

check pd-server
check tikv-server-master
check theflash
check tikv-server-rngine
check tidb-server
