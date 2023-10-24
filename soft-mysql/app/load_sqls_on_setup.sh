#!/usr/bin/env bash

# 环境变量
Pwd=$(realpath $(dirname $0))
Dbn=mzzb_server
Key=fuhaiwei

# 函数定义
function exec {
    echo -e "\033[36;40m  >> $* \033[0m" && $@
}

function load {
    echo "Loading sql file: $1"
    if [ -r $1 ]; then
        mysql -uroot -p$Key $2 <$1 2>/dev/null
    else
        echo "Not found sql file: $1"
    fi
}

# 主要程序
bash $Pwd/wait_for_started.sh
load $Pwd/sqls/setup.sql
load $Pwd/sqls/backup.sql $Dbn
