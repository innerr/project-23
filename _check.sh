#!/bin/bash

source ./_env.sh

function check_pid()
{
	local name="$1"
	echo "=> $name"
	local pid=`get_pid $name`
	if [ -z "$pid" ]; then
		echo -e "   \033[31mnot running\033[0m"
	else
		echo -e "   \033[32m$pid\033[0m"
	fi
}
export -f check_pid

function check_log()
{
	local log="$1"
	local word="$2"
	local title="$3"
	local length="$4"

	if [ ! -f "$log" ]; then
		echo -e "\033[31m   not found: ${log}\033[0m"
	else
		local got=`grep "$word" $log | tail -n 1 | awk '{$1="";print}'`
		if [ -z "$got" ]; then
			echo -e "   \033[32mno ${title}s\033[0m"
		else
			echo -e "  \033[31m${got:0:$length}\033[0m"
		fi
	fi
}
export -f check_log

function show_load()
{
	local dev="$1"
	local load=`uptime | awk '{print $10}' | awk -F ',' '{print $1}'`
	echo "=> LOAD"
	local cores=`grep 'model name' /proc/cpuinfo | wc -l`
	echo -e "   \033[36m$load\033[0m load / $cores cores"
	local io=`iostat -m -d 1 2 | grep "$dev" | tail -n 1 | \
		awk '{print "\033[36m"$2"\033[0m/tps, \033[36m"$3"\033[0mm/r, \033[36m"$4"\033[0mm/w of "$1}'`
	echo -e "   $io"
}
export -f show_load

function show_top_regions()
{
	local n="$1"
	local vertical="$2"

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

	echo -e "=> top $n regions by keys, \033[36m$count\033[0m total"
	if [ "$vertical" == "true" ]; then
		echo "$regions" | while read region; do
			local region_id=`echo $region | awk '{print $1}'`
			local region_keys=`echo $region | awk '{print $2}'`
			echo -e "   region #${region_id}: \033[36m"$region_keys"\033[0m"
		done
	else
		echo -e "   \033[36m"`echo "$regions" | awk '{print $2}'`"\033[0m"
	fi
}
export -f show_top_regions

function show_region_partition()
{
	local n="$1"
	if [ -z "`get_pid 'theflash server'`" ]; then
		return
	fi
	local map=`bin/theflash client --host 127.0.0.1 --port 9000 --query "DBGInvoke dump_region_partition()" \
		2>&1 | awk '{print "   "$0}'`
	if [ -z "$map" ]; then
		return
	fi
	local entrys="`echo "$map" | wc -l`"
	echo -e "=> top partitions, total \033[36m${entrys}\033[0m regions in mapping"
	echo -e "$map" | awk -F '->' '{print $2}' | sort | uniq -c | sort -nrk1 | \
		awk '{print "   \033[36m"$1"\033[0m regions in t"$3,"p"$5}' | head -n "$n"
}
export -f show_region_partition

function check_sync_status()
{
	local log="$1"

	if [ ! -f "$log" ]; then
		echo -e "   \033[31mnot found: ${log}\033[0m"
	else
		local out=`tail -n 10000 "$log" | grep "KVStore: Sync status" | tail -n 1`
		if [ ! -z "$out" ]; then
			local ts=`echo "$out" | awk '{print $2}' | awk -F '\\\.' '{print $1}'`
			local region=`echo "$out" | awk -F 'status: ' '{print $2}'`
			echo -e "   \033[36m$ts\033[0m(`date +%T` now) applied $region"
		fi
	fi
}
export -f check_sync_status

function show_partitions()
{
	local server_path="$1"
	local table="$2"
	local db="$3"

	local old=`pwd`

	cd "$server_path"
	local got=`./analyze-table-compaction.sh "$table" "$db" 2>/dev/null | awk '{print "   "$0}'`
	local count=`echo "$got" | head -n 1 | awk '{print $NF}'`
	echo -e "=> ${db}.${table} status"
	local parts=`echo "$got" | grep "Parts total" | awk '{print $NF}'`
	echo -e "   \033[36m$count\033[0m partitions, \033[36m$parts\033[0m parts"
	echo "$got" | grep "batch size" | awk '{print "   \033[36m"$(NF-2)"\033[0mmb write batch"}'
	echo "$got" | grep "write amp" | awk '{print "   \033[36m"$NF"\033[0m write amplification"}'
	cd "$old"
}
export -f show_partitions
