#!/usr/bin/env bash

# 环境变量
Pwd=$(realpath $(dirname $0))
Cmd=${1:-help}

# 函数定义
function exec {
    echo -e "\033[33m >> RUN: $* \033[0m" && $@
}

function call {
    [ -r soft-rabbitmq/app.sh ] &&
        exec bash soft-rabbitmq/app.sh $1
    [ -r soft-mysql/app.sh ] &&
        exec bash soft-mysql/app.sh $1
    [ -r mzzb-server/app.sh ] &&
        exec bash mzzb-server/app.sh $1
    [ -r mzzb-ui/app.sh ] &&
        exec bash mzzb-ui/app.sh $1
}

function back {
    [ -r mzzb-ui/app.sh ] &&
        exec bash mzzb-ui/app.sh $1
    [ -r mzzb-server/app.sh ] &&
        exec bash mzzb-server/app.sh $1
    [ -r soft-mysql/app.sh ] &&
        exec bash soft-mysql/app.sh $1
    [ -r soft-rabbitmq/app.sh ] &&
        exec bash soft-rabbitmq/app.sh $1
}

function help {
    echo "usage:  app purge"
    echo "usage:  app setup"
    echo "usage:  app build"
    echo "usage:  app clean"
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
clean)
    exec sudo docker image prune -f
    ;;
build | start | stop | status)
    call $Cmd
    ;;
*)
    help
    ;;
esac
