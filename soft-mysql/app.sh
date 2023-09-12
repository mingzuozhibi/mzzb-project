#!/usr/bin/env bash

# 环境变量
Pwd=$(realpath $(dirname $0))
Cmd=${1:-help} && shift
Img=img-soft-mysql
App=app-soft-mysql
Key=fuhaiwei

# 函数定义
function exec {
    echo -e "\033[36;40m >> RUN: $* \033[0m" && $@
}

function main {
    echo -e "\033[33m >> RUN: $Pwd/app.sh $* \033[0m" && bash $Pwd/app.sh $@
}

function help {
    echo "usage:  app purge"
    echo "usage:  app setup"
    echo "usage:  app build"
    echo "usage:  app start"
    echo "usage:  app stop"
    echo "usage:  app logs"
    echo "usage:  app bash"
}

# 主要程序
case $Cmd in
purge)
    exec sudo rm -rf $Pwd/disk
    ;;
setup)
    [ "$1" == "-f" ] && main purge
    [ ! -d $Pwd/disk ] && setup="true"
    [ "$setup" == true ] && exec mkdir -p $Pwd/disk
    main build
    [ "$setup" == true ] && main bash /opt/app/setup.sh
    ;;
build)
    exec sudo docker build -t $Img $Pwd
    exec sudo docker rm -f $App
    exec sudo docker run --name $App \
        --network net-mzzb \
        --hostname soft-mysql \
        -v $Pwd/disk/data:/var/lib/mysql \
        -e MYSQL_ROOT_PASSWORD=$Key \
        -p 3306:3306 \
        -d $Img
    ;;
start | stop | logs)
    sudo docker $Cmd $App
    ;;
bash)
    if [ $# -eq 0 ]; then
        exec sudo docker exec -it $App bash
    else
        exec sudo docker exec $App bash $@
    fi
    ;;
*)
    help
    ;;
esac
