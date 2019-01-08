#!/bin/bash

set -ue
source ./_env.sh

#bin/pd-ctl -u "http://$ip:13579" -d config set cluster-version 2.1.0-rc.2

exec bin/tikv-server-rngine \
    --addr "0.0.0.0:20432" \
    --advertise-addr "$ip:20432" \
    --pd "$ip:13579" \
    --data-dir "./data/rngine" \
    --config config/rngine.toml \
    --log-level info \
    --log-file "./log/rngine.log" 2>> "./log/rngine_stderr.log"
