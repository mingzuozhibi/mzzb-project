#!/usr/bin/env bash

# 环境变量
Tag=soft-rabbitmq
Upstream=rabbitmq:3.12-management

Pwd=$(realpath $(dirname $0))
Cmd=${1:-help} && shift
ImgName=img-$Tag
AppName=app-$Tag

# Main Function
function main_help {
    echo "Usage:  app <cmd> [param1] ..."
    echo ""
    echo "Project Initialize"
    echo "    purge    Clear the data"
    echo "    setup    Build and create"
    echo "    fetch    Pull upstream image"
    echo "    build    Building an image"
    echo "    create   Initialize container"
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

# Hook Function
function pre_setup {
    # Setup rabbitmq data dir
    myrun mkdir $Pwd/volume/rabbitmq -p
}

function docker_run {
    myrun sudo docker run --name $AppName \
        --hostname $Tag \
        --network net-mzzb \
        -v $Pwd/volume/app:/opt/app \
        -v $Pwd/volume/rabbitmq:/var/lib/rabbitmq \
        -e RABBITMQ_DEFAULT_USER=admin \
        -e RABBITMQ_DEFAULT_PASS=admin \
        -p 5672:5672 \
        -p 15672:15672 \
        -d $ImgName
}

source $Pwd/../common.sh
