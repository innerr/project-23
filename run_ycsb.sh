#!/bin/bash

type="$1"
op="$2"

if [ -z "$type" ]; then
	echo "usage: <bin> type(tikv|tidb) operator(load|run)" >&2
	exit 1
fi

source ./_env.sh
if [ "$type" == "tikv" ]; then
	./bin/go-ycsb $op tikv -p tikv.pd="http://$ip:13579" -p tikv.type="txn" --threads 10 -P workloada >> log/ycsb_txn.log
else
	if [ "$type" == "tidb" ]; then
		bin/go-ycsb $op mysql -P workloada -p mysql.host=$ip -p mysql.port="12490" -p mysql.user="root"
	else
		echo "error: unsupported: $type" >&2
		exit 1
	fi
fi
