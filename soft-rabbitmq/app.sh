#!/usr/bin/env bash

# 环境变量
Pwd=$(realpath $(dirname $0))
Cmd=${1:-help}
Img=img-soft-rabbitmq
App=app-soft-rabbitmq

# 函数定义
function exec {
    echo -e "\033[36;40m >> RUN: $* \033[0m" && $@
}

function help {
    echo "usage:  app setup"
    echo "usage:  app start"
    echo "usage:  app stop"
    echo "usage:  app logs"
    echo "usage:  app bash"
    echo "usage:  app pull"
    echo "usage:  app build"
    echo "usage:  app clean"
}

# 主要程序
case $Cmd in
setup)
    exec sudo rm -rf disk
    exec mkdir -p disk
    exec bash $0 build
    ;;
start | stop | logs)
    sudo docker $Cmd $App
    ;;
bash)
    exec sudo docker exec -it $App bash
    ;;
pull)
    exec sudo docker pull mysql:8.0-debian
    ;;
build)
    exec sudo docker build -t $Img $Pwd
    exec sudo docker rm -f $App
    exec sudo docker run --name $App \
        --network net-mzzb \
        -v $Pwd/disk/data:/var/lib/rabbitmq \
        -p 5672:5672 \
        -p 15672:15672 \
        -d $Img
    ;;
*)
    help
    ;;
esac
