#!/bin/bash

set -eu

deamon="$1"

if [ "$deamon" == "true" ]; then
	bin/theflash server --config-file "config/config.xml" >./log/theflash.log 2>./log/theflash_stderr.log &
else
	bin/theflash server --config-file "config/config.xml" >./log/theflash.log 2>./log/theflash_stderr.log
fi
