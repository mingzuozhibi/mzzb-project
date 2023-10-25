#!/usr/bin/env bash

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

function mytfn {
    [ "$(type -t $1)" == "function" ] &&
        myfmt "36;40" " >> RUN: $Tag/hook $*" && $@
}

function help_setup {
    echo "Project Initialize"
    echo "    purge    Clear the data"
    echo "    setup    Build and create"
    echo "    fetch    Pull upstream image"
    echo "    build    Building an image"
    echo "    create   Initialize container"
}

function help_start {
    echo "Operation and maintenance"
    echo "    start    Run the container"
    echo "    stop     Stop the container"
    echo "    status   Check alive status"
}

function help_ohter {
    echo "Development and other"
    echo "    logs     Show container logs"
    echo "    bash     Attach to container"
    echo "    exec     Run container command"
    echo "    help     Display this help"
}

if [ "$(sudo service docker status)" != "Docker is running." ]; then
    sudo service docker start
    while /bin/true; do
        sleep 1
        [ "$(sudo service docker status)" == "Docker is running." ] && break
    done
fi

myfmt "33" " >> CMD: $Tag/app $Cmd $*"

case $Cmd in
purge)
    [ $(sudo docker ps -a | grep $AppName | wc -l) -eq 1 ] &&
        myrun sudo docker rm -f $AppName
    [ $(sudo docker image ls | grep $ImgName | wc -l) -eq 1 ] &&
        myrun sudo docker rmi $ImgName
    myrun sudo rm -rf $Pwd/volume
    ;;
setup)
    [ "$1" == "-f" ] && (
        mycmd purge
        mycmd fetch
        mytfn build_code
    )
    [ "$1" == "-c" ] && mytfn build_code
    [ -d "$Pwd/volume" ] || first="true"
    [ "$first" == "true" ] && mytfn pre_setup
    mycmd build
    mycmd create
    [ "$first" == "true" ] && mytfn post_setup
    ;;
fetch | pull)
    myrun sudo docker pull $Upstream
    ;;
build)
    mytfn pre_build
    myrun sudo docker build -t $ImgName $Pwd
    ;;
create | run)
    [ $(sudo docker ps -a | grep $AppName | wc -l) -eq 1 ] &&
        myrun sudo docker rm -f $AppName
    docker_run
    ;;
start | stop | logs)
    myrun sudo docker $Cmd $AppName
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
bash)
    myrun sudo docker exec -it $AppName bash
    ;;
exec)
    myrun sudo docker exec -i $AppName $@
    ;;
*)
    main_fn="main_$Cmd"
    if [ "$(type -t $main_fn)" == "function" ]; then
        myrun $main_fn $@
    else
        echo "Unknown command: app $Cmd $*"
        echo ""
        main_help
    fi
    ;;
esac
