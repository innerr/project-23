#!/bin/bash

set -ue
source ./_env.sh

echo "=> stop tidb"
stop tidb-server true
