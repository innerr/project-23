#!/bin/bash

set -ue
source ./_env.sh

./stop_all.sh

echo "=> remove all data"
#./reset.sh
./cleanup.sh

echo "=> run pd"
./run_pd.sh &

sleep 5

echo "=> run tikv"
./run_tikv.sh &

sleep 5

echo "=> run tidb"
./run_tidb.sh &

sleep 5

echo "=> run theflash"
./run_theflash.sh true false

sleep 5

echo "=> run rngine"
./run_rngine.sh &

./check_all.sh

#pd_ctl "op add add-learner 2 4"
#pd_ctl "config set max-merge-region-keys 0" 1>/dev/null
#pd_ctl "config set max-merge-region-size 0" 1>/dev/null
