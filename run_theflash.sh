#!/bin/bash

deamon="$1"
run_rngine="$2"

if [ -z "$deamon" ]; then
	deamon="true"
fi

if [ -z "$run_rngine" ]; then
	run_rngine="true"
fi

set -eu

if [ "$deamon" == "false" ]; then
	bin/theflash server --config-file "config/config.xml" >./log/theflash.log 2>./log/theflash_stderr.log
else
	bin/theflash server --config-file "config/config.xml" >./log/theflash.log 2>./log/theflash_stderr.log &
	if [ "$run_rngine" != "false" ]; then
		sleep 3
		./run_rngine.sh &
	fi
fi
