#!/bin/bash

set -ue
source ./_env.sh

echo "=> stop theflash"
stop "theflash server" true

echo "=> stop rngine"
stop tikv-server-rngine
