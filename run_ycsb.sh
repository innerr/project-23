#!/bin/bash

type="$1"
op="$2"
workload="$3"

if [ -z "$type" ] || [ -z "$op" ]; then
	echo "usage: <bin> type(tikv|tidb) operator(load|run) [workload file]" >&2
	exit 1
fi

if [ -z "$workload" ]; then
	workload="workload/test"
fi

source ./_env.sh
if [ "$type" == "tikv" ]; then
	./bin/go-ycsb $op tikv -p tikv.pd="http://$ip:13579" -p tikv.type="txn" --threads 10 -P $workload
else
	if [ "$type" == "tidb" ]; then
		bin/go-ycsb $op mysql -P $workload -p mysql.host=$ip -p mysql.port="12490" -p mysql.user="root"
	else
		echo "error: unsupported: $type" >&2
		exit 1
	fi
fi
