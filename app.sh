#!/usr/bin/env bash

# 环境变量
Pwd=$(realpath $(dirname $0))
Cmd=${1:-help} && shift

# 函数定义
function exec {
    echo -e "\033[36;40m >> $* \033[0m" && $@
}

function main {
    if [ $# -eq 1 ]; then
        echo -e "\033[32m >> RUN: root/app $1 \033[0m" && bash $Pwd/app.sh $1
    else
        echo -e "\033[33m >> RUN: $1/app $2 \033[0m" && bash $Pwd/$1/app.sh $2
    fi
}

function call {
    for path in soft-mysql soft-rabbitmq mzzb-server mzzb-ui; do
        main $path $1
    done
}

function back {
    for path in mzzb-ui mzzb-server soft-rabbitmq soft-mysql; do
        main $path $1
    done
}

function help {
    echo "usage:  app purge"
    echo "usage:  app setup"
    echo "usage:  app build"
    echo "usage:  app start"
    echo "usage:  app stop"
    echo "usage:  app test"
    echo "usage:  app dev"
}

# 前置依赖
if [ "$(sudo service docker status)" == "Docker is not running ... failed!" ]; then
   sudo service docker start && sleep 2
fi


# 主要程序
case $Cmd in
purge)
    [ $(sudo docker network ls | grep net-mzzb | wc -l) -lt 0 ] &&
        exec sudo docker network rm net-mzzb
    back $Cmd
    ;;
setup)
    [ "$1" == "-f" ] && main purge
    [ $(sudo docker network ls | grep net-mzzb | wc -l) -eq 0 ] &&
        exec sudo docker network create net-mzzb
    call $Cmd
    ;;
build)
    back stop
    call $Cmd
    ;;
start)
    call $Cmd
    ;;
stop)
    back $Cmd
    ;;
test)
    for path in soft-mysql soft-rabbitmq mzzb-server mzzb-ui; do
        bash $Pwd/$path/app.sh $Cmd
    done
    ;;
dev)
    for path in soft-mysql soft-rabbitmq; do
        [ -r $path/app.sh ] && exec bash $path/app.sh setup
    done
    ;;
*)
    help
    ;;
esac
