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
	local pid=`ps -ef | grep "bin/$name" | grep -v grep`
	local pid_count=`echo "$pid" | wc -l | awk '{print $1}'`
	if [ "$pid_count" != "1" ]; then
		echo "$name pid count: $pid_count != 1, do nothing" >&2
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
	local fast=""
	if [ ! -z ${2+x} ]; then
		fast="$2"
	fi

	local pid=`get_pid "$name"`
	if [ -z "$pid" ]; then
		return;
	fi
	
	local heavy_kill="false"
	local heaviest_kill="false"

	if [ "$fast" == "true" ]; then
		heaviest_kill="true"
	fi

	set +e
	for ((i=0; i<600; i++)); do
		if [ "$heaviest_kill" == "true" ]; then
			echo "   #$i pid $pid closing, using 'kill -9'..."
			kill -9 $pid
		else
			if [ "$heavy_kill" == "true" ]; then
				echo "   #$i pid $pid closing, using double kill..."
			else
				echo "   #$i pid $pid closing..."
			fi
			kill $pid
			if [ "$heavy_kill" == "true" ]; then
				kill $pid
			fi
		fi

		sleep 1

		pid_exists=`get_pid "$name"`
		if [ -z "$pid_exists" ]; then
			echo "   #$i pid $pid closed"
			break
		fi

		if [ $i -ge 29 ]; then
			heavy_kill="true"
		fi
		if [ $i -ge 39 ]; then
			heaviest_kill="true"
		fi
		if [ $i -ge 119 ]; then
			echo "   pid $pid close failed" >&2
			exit 1
		fi
	done

	# TODO: restore old setting
	set -e
}
export -f stop
