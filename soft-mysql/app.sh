#!/usr/bin/env bash

# Variable
Tag=soft-mysql
Upstream=mysql:8.0-debian

Pwd=$(realpath $(dirname $0))
Cmd=${1:-help} && shift
ImgName=img-$Tag
AppName=app-$Tag

DbName=mzzb_server
DbPass=fuhaiwei
BakFile=$Pwd/backup/backup.sql
Archive=$Pwd/backup/archive
MaxFile=20

# Main Function
function main_help {
    echo "Usage:  app <cmd> [param1] ..."
    echo ""
    help_setup
    echo ""
    help_start
    echo ""
    help_mysql
    echo ""
    help_ohter
}

function help_mysql {
    echo "Operation with MySQL"
    echo "    save     Dump mysql database"
    echo "    load     Load mysql sql file"
}

function main_save {
    if [ $# -eq 0 ]; then
        [ -d $Archive ] || myrun mkdir $Archive -p
        echo "Dumping mysql database $DbName to $BakFile"
        sudo docker exec $AppName mysqldump -uroot -p$DbPass $DbName >$BakFile 2>/dev/null
        myrun cp $BakFile "$Archive/$(date '+%Y%m%d_%H%M%S').sql"
        cd $Archive && ls | xargs -n 1 | head -n -$MaxFile | xargs -n 1 -rt rm
    else
        target_file=$1 && shift
        echo "Dumping mysql database $DbName to $target_file"
        sudo docker exec $AppName mysqldump -uroot -p$DbPass $DbName >$target_file 2>/dev/null
    fi
}

function main_load {
    if [ $# -eq 0 ]; then
        echo "Loading sql file $BakFile to $DbName"
        mycmd exec mysql -uroot -p$DbPass $DbName <$BakFile
        echo "Done"
    else
        target_file=$1 && shift
        echo "Loading sql file $target_file to $DbName"
        mycmd exec mysql -uroot -p$DbPass $DbName <$target_file
        echo "Done"
    fi
}

# Hook Function
function pre_setup {
    # Setup mysql data dir
    myrun mkdir $Pwd/volume/mysql -p
    # Setup script and sqls
    myrun cp $Pwd/app $Pwd/volume -r
}

function post_setup {
    # Load setup.sql and backup.sql
    mycmd exec bash /opt/app/load_sqls_on_setup.sh
}

function docker_run {
    myrun sudo docker run --name $AppName \
        --hostname $Tag \
        --network net-mzzb \
        -v $Pwd/volume/app:/opt/app \
        -v $Pwd/volume/mysql:/var/lib/mysql \
        -e MYSQL_ROOT_PASSWORD=$DbPass \
        -p 3306:3306 \
        -d $ImgName
}

source $Pwd/../common.sh
