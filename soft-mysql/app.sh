#!/usr/bin/env bash

# 环境变量
Pwd=$(realpath $(dirname $0))
Cmd=${1:-help} && shift
Tag=soft-mysql
Img=img-$Tag
App=app-$Tag

Dbn=mzzb_server
Key=fuhaiwei
Bak=$Pwd/baks/backup.sql
Max=20

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
    echo "Operation with MySQL"
    echo "    save     Dump mysql database"
    echo "    load     Load mysql sql file"
    echo ""
    echo "Development and other"
    echo "    logs     Show container logs"
    echo "    exec     Run command or bash"
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
    [ ! -d $Pwd/disk ] && setup="true"
    exec mkdir -p $Pwd/baks/date
    exec mkdir -p $Pwd/disk/data
    main build
    [ "$setup" == true ] && main exec bash /opt/app/setup.sh
    ;;
build)
    exec sudo docker build -t $Img $Pwd
    exec sudo docker rm -f $App
    exec sudo docker run --name $App \
        --hostname $Tag \
        --network net-mzzb \
        -v $Pwd/disk/data:/var/lib/mysql \
        -e MYSQL_ROOT_PASSWORD=$Key \
        -p 3306:3306 \
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
exec)
    if [ $# -eq 0 ]; then
        exec sudo docker exec -it $App bash
    else
        exec sudo docker exec -i $App $@
    fi
    ;;
save)
    if [ $# -eq 0 ]; then
        echo "Dumping mysql database $Dbn to $Bak"
        sudo docker exec $App mysqldump -uroot -p$Key $Dbn >$Bak 2>/dev/null
        exec cp $Bak "$Pwd/baks/date/$(date '+%Y%m%d_%H%M%S').sql"
        cd $Pwd/baks/date && ls | xargs -n 1 | head -n -$Max | xargs -n 1 -rt rm
    else
        echo "Dumping mysql database $Dbn to $1"
        sudo docker exec $App mysqldump -uroot -p$Key $Dbn >$1 2>/dev/null
    fi
    ;;
load)
    if [ $# -eq 0 ]; then
        echo "Loading sql file $Bak to $Dbn"
        sudo docker exec -i $App mysql -uroot -p$Key $Dbn <$Bak 2>/dev/null
        echo "Done"
    else
        echo "Loading sql file $1 to $Dbn"
        sudo docker exec -i $App mysql -uroot -p$Key $Dbn <$1 2>/dev/null
        echo "Done"
    fi
    ;;
*)
    help
    ;;
esac
