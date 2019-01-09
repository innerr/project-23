#!/bin/bash

set -ue
source ./_env.sh

function check_pid()
{
	local name="$1"
	echo "=> $name"
	local pid=`get_pid $name`
	if [ -z "$pid" ]; then
		echo -e "\033[31m   not running\033[0m"
	else
		echo -e "\033[32m   $pid\033[0m"
	fi
}

function check_log()
{
	local log="$1"
	local word="$2"
	local title="$3"

	if [ ! -f "$log" ]; then
		echo -e "\033[31m   not found: ${log}\033[0m"
	else
		local got=`grep "$word" $log | tail -n 1`
		if [ -z "$got" ]; then
			echo -e "   log no ${title}s"
		else
			echo -e "\033[31m   $title: ${got:0:90}\033[0m"
		fi
	fi
}

function show_cpu()
{
	local load=`uptime | awk '{print $10}' | awk -F ',' '{print $1}'`
	local cores=`grep 'model name' /proc/cpuinfo | wc -l`
	echo "=> CPU"
	echo -e "   \033[36m$load\033[0m load (in 1m) / $cores cores"
}

function show_top_regions()
{
	local n="$1"

	if [ -z "`get_pid pd-server`" ]; then
		return
	fi

	local info=`./bin/pd-ctl -d -u=http://127.0.0.1:13579 region`
	local count=`echo "$info" | grep count | awk '{print $2}' | awk -F ',' '{print $1}'`
	local regions=`echo "$info" | python ./_parse_regions.py \
		| sort -rnk 2 | head -n $n`

	if [ -z "$regions" ]; then
		return
	fi
	echo -e "=> top $n regions from pd (\033[36m$count\033[0m regions total)"
	echo "$regions" | while read region; do
		local region_id=`echo $region | awk '{print $1}'`
		local region_keys=`echo $region | awk '{print $2}'`
		echo -e "   region #${region_id}: \033[36m"$region_keys"\033[0m keys"
	done
}

function show_region_partition()
{
	if [ -z "`get_pid 'theflash server'`" ]; then
		return
	fi
	local map=`bin/theflash client --host 127.0.0.1 --port 9000 --query "DBGInvoke dump_region_partition()" \
		2>&1 | awk '{print "   "$0}'`
	if [ -z "$map" ]; then
		return
	fi
	local entrys="`echo "$map" | wc -l`"
	echo -e "=> region mapping (\033[36m${entrys}\033[0m entrys, show 3 only)"
	echo "$map" | head -n 3
}

check_pid tidb-server
check_log "./log/tidb.log" "ERRO" "error"

check_pid pd-server
check_log "./log/pd.log" "ERRO" "error"

check_pid tikv-server-master
check_log "./log/tikv.log" "ERRO" "error"

check_pid tikv-server-rngine
check_log "./log/rngine.log" "ERRO" "error"

check_pid "theflash server"
check_log "/data/theflash/server.log" "Error" "error"
check_log "/data/theflash/server.log" "Warning" "warning"

show_cpu
show_top_regions 3
show_region_partition
