#!/bin/bash

set -ue
source ./_env.sh

exec bin/rng \
    --addr "0.0.0.0:3930" \
    --config "./rng.toml" \
    --log-file "log/mock_ch.log" \
    --data-dir "data.mock_ch" 2>> "log/mock_ch_stderr.log"
