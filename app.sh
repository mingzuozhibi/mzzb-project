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

function help {
    echo "usage:  app setup"
    echo "usage:  app start"
    echo "usage:  app stop"
    echo "usage:  app pull"
    echo "usage:  app build"
    echo "usage:  app clean"
}

# 主要程序
case $Cmd in
setup)
    [ $(sudo docker network ls | grep net-mzzb | wc -l) -eq 0 ] &&
        exec sudo docker network create net-mzzb
    call $Cmd
    ;;
start | stop | pull | build)
    call $Cmd
    ;;
clean)
    exec sudo docker image prune -f
    ;;
*)
    help
    ;;
esac
