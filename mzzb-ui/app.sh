#!/usr/bin/env bash

# Variable
Tag=mzzb-ui
Upstream=nginx:stable

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
    volume_www=$Pwd/volume/app/www
    myrun mkdir -p $volume_www
}

function build_code {
    myrun cd $Pwd && myrun yarn && myrun yarn build
}

function pre_build {
    build_path=$Pwd/build
    volume_www=$Pwd/volume/app/www
    [ -d $build_path ] || mytfn build_code
    [ -d $volume_www ] || mytfn pre_setup
    myrun rsync -av --delete $build_path/ $volume_www
}

function docker_run {
    myrun sudo docker run -it --name $AppName \
        --hostname $Tag \
        --network net-mzzb \
        -v $Pwd/volume/app:/opt/app \
        -p 3000:3000 \
        -d $ImgName
}

source $Pwd/../common.sh
