#!/bin/bash

cleanup="$1"

set -ue

source ./_env.sh

if [ -z "$cleanup" ]; then
	cleanup="false"
fi

./stop_all.sh

if [ "$cleanup" == "true" ]; then
	echo "=> remove all data"
	./cleanup.sh
fi

echo "=> run pd"
./run_pd.sh &

sleep 5

echo "=> run tikv"
./run_tikv.sh &

sleep 5

echo "=> run tidb"
./run_tidb.sh &

sleep 5

echo "=> run theflash"
./run_theflash.sh true false

sleep 5

echo "=> run rngine"
./run_rngine.sh &

./check_all.sh
