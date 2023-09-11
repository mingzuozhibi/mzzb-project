#!/usr/bin/env bash

# 环境变量
Pwd=$(realpath $(dirname $0))
Cmd=${1:-help}
Img=img-soft-mysql
App=app-soft-mysql
Key=fuhaiwei

# 函数定义
function exec {
    echo -e "\033[36;40m >> RUN: $* \033[0m" && $@
}

function load {
    echo "Load sql file: $1"
    mysql -uroot -p$Key -h127.0.0.1 $2 <$1
}

function wait_for_started {
    while /bin/true; do
        sleep 1
        mysqladmin -h127.0.0.1 ping >/dev/null 2>&1 && break
    done
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
    if [ ! -d $Pwd/disk ]; then
        exec mkdir -p $Pwd/disk
        first="true"
    fi
    exec bash $0 build
    if [ "$first" == "true" ]; then
        echo "Waiting for MySQL to start" && wait_for_started
        load $Pwd/sqls/setup.sql
        [ -r $Pwd/sqls/backup.sql ] &&
            load $Pwd/sqls/backup.sql mzzb_server
    fi
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
    exec sudo docker exec -it $App bash
    ;;
*)
    help
    ;;
esac
