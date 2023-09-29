#!/usr/bin/env bash

# 环境变量
Pwd=$(realpath $(dirname $0))
Cmd=${1:-help} && shift
Tag=mzzb-ui
Img=img-$Tag
App=app-$Tag

# 函数定义
function myfmt {
    color=$1 && shift
    echo -e "\033[${color}m$*\033[0m"
}

function myrun {
    myfmt "36;40" " >> RUN: $*" && $@
}

function mycmd {
    bash $Pwd/app.sh $@
}

function myhelp {
    echo "Usage:  app <cmd> [param1] ..."
    echo ""
    echo "Project Initialize"
    echo "    purge    Clear the data"
    echo "    setup    Compile and Build"
    echo "    build    Build the image"
    echo ""
    echo "Operation and maintenance"
    echo "    start    Run the container"
    echo "    stop     Stop the container"
    echo "    status   Check alive status"
    echo ""
    echo "Development and other"
    echo "    logs     Show container logs"
    echo "    exec     Run command or bash"
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

myfmt "33" " >> CMD: $Tag/app $Cmd $*"

# 主要程序
case $Cmd in
purge)
    mycmd status >/dev/null && mycmd stop
    myrun sudo rm -rf $Pwd/disk
    ;;
setup)
    [ "$1" == "-f" ] && mycmd purge
    myrun mkdir -p $Pwd/disk/www
    myrun cd $Pwd && yarn && yarn build
    myrun cp $Pwd/build/* $Pwd/disk/www -r
    mycmd build
    ;;
build)
    myrun sudo docker build -t $Img $Pwd
    [ $(sudo docker ps -a | grep $Tag | wc -l) -eq 1 ] &&
        myrun sudo docker rm -f $App
    myrun sudo docker run -it --name $App \
        --hostname $Tag \
        --network net-mzzb \
        -v $Pwd/disk:/opt/app \
        -p 3000:3000 \
        -d $Img
    ;;
start | stop | logs)
    myrun sudo docker $Cmd $App
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
exec)
    if [ $# -eq 0 ]; then
        myrun sudo docker exec -it $App bash
    else
        myrun sudo docker exec -i $App $@
    fi
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
