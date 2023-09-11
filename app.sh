#!/usr/bin/env bash

# 环境变量
Pwd=$(realpath $(dirname $0))
Cmd=${1:-help}

# 函数定义
function exec {
    echo -e "\033[33m >> RUN: $* \033[0m" && $@
}

function call {
    for path in soft-mysql soft-rabbitmq mzzb-server mzzb-ui; do
        [ -r $path/app.sh ] && exec bash $path/app.sh $1
    done
}

function back {
    for path in mzzb-ui mzzb-server soft-rabbitmq soft-mysql; do
        [ -r $path/app.sh ] && exec bash $path/app.sh $1
    done
}

function help {
    echo "usage:  app purge"
    echo "usage:  app setup"
    echo "usage:  app build"
    echo "usage:  app start"
    echo "usage:  app stop"
}

# 主要程序
case $Cmd in
purge)
    back stop
    [ $(sudo docker network ls | grep net-mzzb | wc -l) -lt 0 ] &&
        exec sudo docker network rm net-mzzb
    call $Cmd
    ;;
setup)
    [ "$2" == "-f" ] && exec bash $0 purge
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
*)
    help
    ;;
esac
