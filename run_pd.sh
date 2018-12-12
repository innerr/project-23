#!/bin/bash

set -ue
source ./_env.sh

exec bin/pd-server \
    --name="pd1" \
    --client-urls="http://$ip:13579" \
    --advertise-client-urls="http://$ip:13579" \
    --peer-urls="http://$ip:13580" \
    --advertise-peer-urls="http://$ip:13580" \
    --data-dir="./data.pd" \
    --initial-cluster="pd1=http://$ip:13580" \
    --config=pd.toml \
    --log-file="./log/pd.log" 2>> "./log/pd_stderr.log"
