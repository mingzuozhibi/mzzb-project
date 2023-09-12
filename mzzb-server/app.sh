#!/usr/bin/env bash

# 环境变量
Pwd=$(realpath $(dirname $0))
Cmd=${1:-help} && shift
Tag=mzzb-server
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
    echo "usage:  app purge"
    echo "usage:  app setup"
    echo "usage:  app build"
    echo "usage:  app start"
    echo "usage:  app stop"
    echo "usage:  app logs"
    echo "usage:  app test"
    echo "usage:  app bash"
}

# 主要程序
case $Cmd in
purge)
    main test >/dev/null && main stop
    exec sudo rm -rf $Pwd/disk
    ;;
setup)
    [ "$1" == "-f" ] && main purge
    exec mkdir -p $Pwd/disk
    exec cd $Pwd && mvn clean package
    exec cp $Pwd/target/*.jar $Pwd/disk/app.jar
    exec cp $Pwd/etc $Pwd/disk -r
    main build
    ;;
build)
    exec sudo docker build -t $Img $Pwd
    exec sudo docker rm -f $App
    exec sudo docker run -it --name $App \
        --hostname $Tag \
        --network net-mzzb \
        -v $Pwd/disk:/opt/app \
        -p 9000:9000 \
        -d $Img
    ;;
start | stop | logs)
    exec sudo docker $Cmd $App
    ;;
test)
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
        exec sudo docker exec $App bash $@
    fi
    ;;
*)
    help
    ;;
esac
