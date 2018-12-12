source ./_env.sh
bin/pd-ctl -u "http://$ip:13579" -d $@
