#!/bin/bash

set -ue
source ./_env.sh

echo "=> stop pd-server"
stop pd-server

echo "=> stop tikv-server-master"
stop tikv-server-master

echo "=> stop tikv-server-rngine"
stop tikv-server-rngine

echo "=> stop tidb"
stop tidb-server

echo "=> stop theflash"
stop theflash
