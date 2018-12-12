#!/bin/bash

set -ue
source ./_env.sh

./stop_all.sh

echo "=> remove all data"
./reset.sh

echo "=> run pd"
./run_pd.sh &

sleep 3

echo "=> run tikv"
./run_tikv.sh &

sleep 2

echo "=> run rngine"
./run_rngine.sh &

./check_all.sh

./pd_ctl.sh op add add-learner 2 4
./pd_ctl.sh config set max-merge-region-keys 0 1>/dev/null
./pd_ctl.sh config set max-merge-region-size 0 1>/dev/null
