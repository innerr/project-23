#!/bin/bash

set -ue
source ./_check.sh

len="110"

check_pid tidb-server
check_log "./log/tidb.log" "ERRO" "error" "$len"

check_pid pd-server
check_log "./log/pd.log" "ERRO" "error" "$len"

check_pid tikv-server-master
check_log "./log/tikv.log" "ERRO" "error" "$len"

check_pid tikv-server-rngine
check_log "./log/rngine.log" "ERRO" "error" "$len"

check_pid "theflash server"
check_log "/data/theflash/server.log" "Error" "error" "$len"
check_log "/data/theflash/server.log" "Warning" "warning" "$len"
check_sync_status "/data/theflash/server.log"

show_load "nvme0n1"
show_top_regions 6 "false"

show_partitions "../theflash-newest" "lineitem" "tpch50"
show_region_partition 10
