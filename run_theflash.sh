#!/bin/bash

deamon="$1"

set -eu

if [ "$deamon" == "false" ]; then
	bin/theflash server --config-file "config/config.xml" >./log/theflash.log 2>./log/theflash_stderr.log
else
	bin/theflash server --config-file "config/config.xml" >./log/theflash.log 2>./log/theflash_stderr.log &
fi
