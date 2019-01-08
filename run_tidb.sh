#!/bin/bash

set -ue
source ./_env.sh

exec bin/tidb-server \
    -P 12490 \
    --status="10080" \
    --advertise-address="$ip" \
    --path="$ip:13579" \
    --config="config/tidb.toml" \
    --log-file="log/tidb.log" 2>> "log/tidb_stderr.log"
