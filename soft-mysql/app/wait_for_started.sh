#!/usr/bin/env bash

# 环境变量
Key=fuhaiwei

# 主要程序
echo "Waiting for MySQL to start"
while /bin/true; do
    sleep 1
    [ "$(mysqladmin -uroot -p$Key ping 2>/dev/null)" == "mysqld is alive" ] && break
done
