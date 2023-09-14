#!/usr/bin/env bash

# 环境变量
Pwd=$(realpath $(dirname $0))
Cmd=${1:-help} && shift
Tag=soft-rabbitmq
Img=img-$Tag
App=app-$Tag

# 函数定义
function exec {
    echo -e "\033[36;40m >> $* \033[0m" && $@
}

function main {
    echo -e "\033[33m >> RUN: $Tag/app $* \033[0m" && bash $Pwd/app.sh $@
}

function help {
    echo "Usage:  app <cmd> [param1] ..."
    echo ""
    echo "Project Initialize"
    echo "    purge    Clear all data"
    echo "    setup    Compile and Build"
    echo "    build    Build all image"
    echo ""
    echo "Operation and maintenance"
    echo "    start    Run all containers"
    echo "    stop     Stop all containers"
    echo "    status   Check alive status"
    echo ""
    echo "Development and other"
    echo "    logs     Show container logs"
    echo "    bash     Run command or bash"
    echo "    help     Display this help"
}

# 主要程序
case $Cmd in
purge)
    main status >/dev/null && main stop
    exec sudo rm -rf $Pwd/disk
    ;;
setup)
    [ "$1" == "-f" ] && main purge
    exec mkdir -p $Pwd/disk/data
    main build
    ;;
build)
    exec sudo docker build -t $Img $Pwd
    exec sudo docker rm -f $App
    exec sudo docker run --name $App \
        --hostname $Tag \
        --network net-mzzb \
        -v $Pwd/conf.d:/etc/rabbitmq/conf.d:ro \
        -v $Pwd/disk/data:/var/lib/rabbitmq \
        -e RABBITMQ_DEFAULT_USER=admin \
        -e RABBITMQ_DEFAULT_PASS=admin \
        -p 5672:5672 \
        -p 15672:15672 \
        -d $Img
    ;;
start | stop | logs)
    exec sudo docker $Cmd $App
    ;;
status)
    if [ $(sudo docker ps | grep $Tag | wc -l) -eq 1 ]; then
        echo "$Tag is alive"
        /bin/true
    else
        echo "$Tag is not alive"
        /bin/false
    fi
    ;;
bash)
    if [ $# -eq 0 ]; then
        exec sudo docker exec -it $App bash
    else
        exec sudo docker exec -i $App $@
    fi
    ;;
*)
    help
    ;;
esac
