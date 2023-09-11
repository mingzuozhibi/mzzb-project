#!/usr/bin/env bash

# 环境变量
Pwd=$(realpath $(dirname $0))
Cmd=${1:-help}
Img=img-mzzb-server
App=app-mzzb-server

# 函数定义
function exec {
    echo -e "\033[36;40m >> RUN: $* \033[0m" && $@
}

function help {
    echo "usage:  app purge"
    echo "usage:  app setup"
    echo "usage:  app build"
    echo "usage:  app clean"
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
    exec mkdir -p $Pwd/disk
    exec bash $0 build
    ;;
build)
    exec cd $Pwd && mvn clean package
    exec cp $Pwd/target/*.jar $Pwd/disk/app.jar
    exec cp $Pwd/etc $Pwd/disk -r
    exec sudo docker build -t $Img $Pwd
    exec sudo docker rm -f $App
    exec sudo docker run -it --name $App \
        --network net-mzzb \
        --hostname mzzb-server \
        -v $Pwd/disk:/opt/app \
        -d $Img
    ;;
start | stop | logs)
    sudo docker $Cmd $App
    ;;
bash)
    exec sudo docker exec -it $App bash
    ;;
*)
    help
    ;;
esac
