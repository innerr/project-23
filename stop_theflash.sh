#!/bin/bash

set -ue
source ./_env.sh

echo "=> stop theflash"
stop theflash

echo "=> stop rngine"
stop tikv-server-rngine
