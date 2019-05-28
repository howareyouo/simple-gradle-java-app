#!/usr/bin/env bash
source /etc/profile
set -x
jarfile=${1}
jarname=$(echo "${jarfile}" | sed 's/.jar$//')
port=${2:-8080}
env=${3:-test}
directory=${4:-'/opt'}
jarfile_fullpath=${directory}/${jarfile}
set +x

# Query pid by listening tcp port
function pid_by_port() {
    [[ $# -lt 1 ]] && { echo 'Param error: must have one param(port)'; return -1; }
    [[ $# -gt 1 ]] && { echo 'Param error: only support one param(port)'; return -1; }

	pattern=":$1\\b"
	pid=$(ss -lntp | grep "${pattern}" | column -t | awk -F ',' '{print $(NF-1)}')

	# column -t 会给出如下格式:
	# 	LISTEN  0  128  :::8080  :::*  users:(("docker-proxy",pid=7923,fd=4))
	# 使用 awk -F ',' 分隔后打印 NF-1 (分割后的字段数的倒数第2个)会得到:
	# 	pid=7923
	# 进一步处理, 获取进程 PID 值.
	[[ ${pid} =~ "pid" ]] && pid=$(echo ${pid} | awk -F '=' '{print $NF}')
	echo ${pid}
}

function stop() {
    echo "Stoping process on port: ${port}"

    pid=$(pid_by_port ${port})
    echo ${pid}
	if [[ -n "$pid" ]]
    then
	    echo "Find pid: ${pid}, kill it..."
	    kill -9 ${pid}
    else
	    echo "No process listening on port: ${port}, proceed..."
	fi
    echo " "
}

function start() {
    nohup nice java -jar ${jarfile_fullpath} --server.port=${port} &> "${jarname}.log" &
    echo  "nohup nice java -jar ${jarfile_fullpath} --server.port=${port} &> "${jarname}.log" &"
	echo " "
}

####################
cd ${directory}
stop
start
