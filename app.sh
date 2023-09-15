#!/usr/bin/env bash

# 环境变量
Pwd=$(realpath $(dirname $0))
Cmd=${1:-help} && shift

# 函数定义
function myfmt {
    color=$1 && shift
    echo -e "\033[${color}m$*\033[0m"
}

function myrun {
    myfmt "36;40" " >> RUN: $*" && $@
}

function mycmd {
    if [ "$1" != "-s" ]; then
        bash $Pwd/app.sh $@
    else
        path=$2 && shift 2 && bash $Pwd/$path/app.sh $@
    fi
}

function mysub {
    if [ "$1" != "-r" ]; then
        for path in soft-mysql soft-rabbitmq mzzb-server mzzb-ui; do
            mycmd -s $path $@
        done
    else
        shift
        for path in mzzb-ui mzzb-server soft-rabbitmq soft-mysql; do
            mycmd -s $path $@
        done
    fi
}

function myhelp {
    echo "Usage:  app <cmd> [param1] ..."
    echo ""
    echo "Project Initialize"
    echo "    purge    Clear all data"
    echo "    setup    Compile and Build"
    echo "    build    Build all images"
    echo "    clean    Clean dangling images "
    echo ""
    echo "Operation and maintenance"
    echo "    start    Run all containers"
    echo "    stop     Stop all containers"
    echo "    status   Check alive status"
    echo ""
    echo "Development and other"
    echo "    dev      Run mysql and rabbitmq"
    echo "    help     Display this help"
}

# 前置依赖
if [ "$(sudo service docker status)" != "Docker is running." ]; then
    sudo service docker start
    while /bin/true; do
        [ "$(sudo service docker status)" == "Docker is running." ] && break
        sleep 1
    done
fi

myfmt "32" " >> CMD: root/app $Cmd $*"

# 主要程序
case $Cmd in
purge)
    [ $(sudo docker network ls | grep net-mzzb | wc -l) -lt 0 ] &&
        myrun sudo docker network rm net-mzzb
    mysub -r $Cmd
    ;;
setup)
    [ "$1" == "-f" ] && mycmd purge
    [ $(sudo docker network ls | grep net-mzzb | wc -l) -eq 0 ] &&
        myrun sudo docker network create net-mzzb
    mysub $Cmd
    mycmd clean
    ;;
build)
    mysub $Cmd
    mycmd clean
    ;;
clean)
    myrun sudo docker image prune -f
    ;;
start)
    mysub $Cmd
    ;;
stop)
    mysub -r $Cmd
    ;;
status)
    for path in soft-mysql soft-rabbitmq mzzb-server mzzb-ui; do
        mycmd -s $path $Cmd >/dev/null && alive="Alive" || alive="Exited"
        printf "%-20s %s\n" "$path" "$alive"
    done
    ;;
dev)
    for path in soft-mysql soft-rabbitmq; do
        mycmd -s $path setup
    done
    ;;
help)
    myhelp
    ;;
*)
    echo "Unknown command: app $Cmd $*"
    echo ""
    myhelp
    ;;
esac
