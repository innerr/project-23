#!/bin/bash

detail="$1"

set -ue
source ./_check.sh

len="75"

echo -e "   \033[34;7;1mDeployment `hostname`\033[0m"

check_pid tidb-server
check_log "./log/tidb.log" "ERRO" "error" "$len" false

check_pid pd-server
check_log "./log/pd.log" "ERRO" "error" "$len" false

check_pid tikv-server-master
check_log "./log/tikv.log" "ERRO" "error" "$len" false

check_pid tikv-server-rngine
check_log "./log/rngine.log" "ERRO" "error" "$len" false

check_pid "theflash server"
check_log "/data/theflash/server.log" "Error" "error" "$len" true
check_log "/data/theflash/server.log" "Warning" "warning" "$len" false
if [ "$detail" == "true" ]; then
	check_sync_status "/data/theflash/server.log"
	check_move_status "/data/theflash/server.log"
fi

show_load "nvme0n1"
show_top_regions 4

if [ "$detail" == "true" ]; then
	source ../tpch-scripts/_env.sh
	show_partitions "../theflash-newest" "lineitem" "tpch${scale}"
	show_partitions "../theflash-newest" "partsupp" "tpch${scale}"
	show_partitions "../theflash-newest" "usertable" "test"
fi

show_region_partition 4
