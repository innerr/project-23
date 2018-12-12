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
	local pid=`ps -ef | grep $name | grep -v grep`
	local pid_count=`echo "$pid" | wc -l | awk '{print $1}'`
	if [ "$pid_count" != "1" ]; then
		echo "$name pid count: $pid_count != 1, exiting..." >&2
		exit 1
	fi
	echo $pid | awk '{print $2}'
}
export -f get_pid
