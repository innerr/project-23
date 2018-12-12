#!/bin/bash

set -ue
source ./_env.sh

exec bin/tikv-server-master \
    --addr "0.0.0.0:20431" \
    --advertise-addr "$ip:20431" \
    --pd "$ip:13579" \
    --data-dir "./data/tikv" \
    --log-level info \
    --config config/tikv.toml \
    --log-file "./log/tikv.log" 2>> "./log/tikv_stderr.log"
