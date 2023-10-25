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
    echo "    setup    Build and create"
    echo "    fetch    Pull all upstream images"
    echo "    build    Building all images"
    echo "    create   Initialize all containers"
    echo ""
    echo "Operation and maintenance"
    echo "    start    Run all containers"
    echo "    stop     Stop all containers"
    echo "    restart  Restart all containers"
    echo "    status   Check alive status"
    echo ""
    echo "Development and other"
    echo "    dev      Run mysql and rabbitmq"
    echo "    ps       List docker containers"
    echo "    clean    Remove unused images"
    echo "    images   List docker images"
    echo "    help     Display this help"
}

# 前置依赖
if [ "$(sudo service docker status)" != "Docker is running." ]; then
    sudo service docker start
    while /bin/true; do
        sleep 1
        [ "$(sudo service docker status)" == "Docker is running." ] && break
    done
fi

myfmt "32" " >> CMD: root/app $Cmd $*"

# 主要程序
case $Cmd in
purge)
    mysub -r $Cmd
    [ $(sudo docker network ls | grep net-mzzb | wc -l) -lt 0 ] &&
        myrun sudo docker network rm net-mzzb
    ;;
setup)
    mysub -r stop
    [ $(sudo docker network ls | grep net-mzzb | wc -l) -eq 0 ] &&
        myrun sudo docker network create net-mzzb
    mysub $Cmd $1
    mycmd clean
    ;;
fetch | pull | build)
    mysub $Cmd
    mycmd clean
    ;;
create | run)
    mysub -r stop
    mysub $Cmd
    mycmd clean
    ;;
ps)
    myrun sudo docker ps $@
    ;;
clean | prune)
    myrun sudo docker image prune -f
    ;;
images | ls)
    myrun sudo docker image ls
    ;;
start)
    mysub $Cmd
    ;;
stop)
    mysub -r $Cmd
    ;;
restart)
    mysub -r stop
    mysub start
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
