# mzzb-project 项目文档

- 本文档以 Debian 系统为例进行说明
- 请确保使用的 Shell 是 Bash v5.x
- 您需要安装好 Git 命令

### 获取项目代码

```shell
git clone https://github.com/mingzuozhibi/mzzb-project ~/mzzb-project
```

### 配置命令别名

```shell
tee ~/.mzzbrc <<EOF
alias app='bash app.sh'
alias cdm='cd ~/mzzb-project'
alias dk='sudo docker'
alias dki='sudo docker image'
alias dks='sudo service docker'
EOF
source ~/.mzzbrc
echo "source ~/.mzzbrc" >> ~/.profile
```

### 安装 docker 环境

其他系统也可参阅 https://docs.docker.com/engine/install/

```shell
# Run the following command to uninstall all conflicting packages:
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > dev/null
sudo apt-get update

# To install the latest version, run:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 项目初始化

```shell
# 一键初始化
app setup
# soft-mysql setup / build image / run container / import dll.sql and data.sql
# soft-rabbitmq setup / build image / run container / add user and set permissions
# mzzb-server setup / build image / copy and edit config /run container
# mzzb-ui setup / build image / run container
```

### 启动与停止

```shell
app start
app stop
```

### 更新与重启

```shell
app pull
app build
app clean
```
