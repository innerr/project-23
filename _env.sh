export ip="127.0.0.1"

export RUST_BACKTRACE=1
export RUST_LOG=debug

export TZ=${TZ:-/etc/localtime}
#export TZ=Asia/Shanghai
export GRPC_VERBOSITY=DEBUG
#export GRPC_TRACE=all

#ulimit -n 1000000
mkdir -p "./log"

#echo -n 'sync ... '
#stat=$(time sync)
#echo ok
#echo $stat

function get_pid()
{
	local name="$1"
	local pid=`ps -ef | grep bin/$name | grep -v grep`
	local pid_count=`echo "$pid" | wc -l | awk '{print $1}'`
	if [ "$pid_count" != "1" ]; then
		echo "$name pid count: $pid_count != 1, exiting..." >&2
		exit 1
	fi
	echo $pid | awk '{print $2}'
}
export -f get_pid

function pd_ctl()
{
	bin/pd-ctl -u "http://$ip:13579" -d $1
}
export -f pd_ctl

function stop()
{
	local name="$1"
	local pid=`get_pid $1`
	if [ ! -z "$pid" ]; then
		kill $pid
	fi
	sleep 0.2
	pid=`get_pid $1`
	if [ ! -z "$pid" ]; then
		kill -9 $pid
	fi
}
export -f stop
