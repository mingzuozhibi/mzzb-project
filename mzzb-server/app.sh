#!/usr/bin/env bash

# Variable
Tag=mzzb-server
Upstream=eclipse-temurin:17

Pwd=$(realpath $(dirname $0))
Cmd=${1:-help} && shift
ImgName=img-$Tag
AppName=app-$Tag

# Main Function
function main_help {
    echo "Usage:  app <cmd> [param1] ..."
    echo ""
    help_setup
    echo ""
    help_start
    echo ""
    help_ohter
}

# Hook Function
function pre_setup {
    volume_etc=$Pwd/volume/app/etc
    myrun mkdir -p $volume_etc
    myrun rsync -av --delete $Pwd/etc/ $volume_etc -r
    # Generate default configuration file
    [ -f $volume_etc/app.properties ] ||
        myrun cp $volume_etc/app.properties.default $volume_etc/app.properties
}

function build_code {
    myrun cd $Pwd && myrun mvn clean package
}

function pre_build {
    build_path=$Pwd/target
    volume_app=$Pwd/volume/app
    [ -d $build_path ] || mytfn build_code
    [ -d $volume_www ] || mytfn pre_setup
    myrun cp $build_path/*.jar $volume_app/app.jar
}

function docker_run {
    myrun sudo docker run -it --name $AppName \
        --hostname $Tag \
        --network net-mzzb \
        -v $Pwd/volume/app:/opt/app \
        -p 9000:9000 \
        -d $ImgName
}

source $Pwd/../common.sh
