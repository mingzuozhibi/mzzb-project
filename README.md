# mzzb-project

本项目是网站 [**mingzuozhibi.com**][mzzb] 的源代码。

_现在已经下线，无法访问。需要获取数据库，以及离线版网站请发 Issue 咨询。_

本网站是为方便 [**名作之壁吧**][home] 的吧友而创建的。本网站以名作之壁吧宗旨和愿景作为指引，在与贴吧功能不冲突的前提下，寻找自己的定位和发展方向。

名作之壁吧以日本动画的销量为主要讨论话题，主要包括动画 BD/DVD、轻小说、漫画、游戏、动画相关 CD 等，兼论动画票房、收视率以及业界商业相关。

名作之壁吧致力于成为动画商业化讨论领域的专业型贴吧，以专业、低调、务实、开放为发展目标，欢迎对动画销量、业界、产业相关话题有兴趣的同好发帖交流。

[home]: https://tieba.baidu.com/f?kw=名作之壁&ie=utf-8
[mzzb]: https://mingzuozhibi.com

### 安装说明

- 本文档以 Debian 系统为例进行说明
- 请确保使用的 Shell 是 Bash v5.x
- 您需要安装好以下软件，版本供参考

  - Git v2.30.x
  - Jdk v17.x
  - Maven 3.8.x
  - Node 18.x
  - Npm 9.x
  - Yarn 1.22.x
  - Docker 24.x

### 安装 Wsl

如果您使用 Linux 物理机或虚拟机，则不需要安装 Wsl

以管理员身份运行 PowerShell（Windows 10）

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

wsl --update
wsl --install Debian
wsl --set-version Debian 2

# 重新启动计算机
```

### 安装 Git

_注意：此后命令不再使用 PowerShell，而是使用 Debian_

```shell
sudo apt install git bash-completion -y
```

### 安装 Jdk, Maven

```shell
sudo apt install openjdk-17-jdk-headless maven -y
```

### 安装 Node, Npm, Yarn

```shell
sudo apt install wget -y
mkdir ~/.local/opt/nodejs -p && cd ~/.local/opt/nodejs
wget https://nodejs.org/dist/v18.17.1/node-v18.17.1-linux-x64.tar.gz
tar -xzvf node-v18.17.1-linux-x64.tar.gz
sudo npm -g i yarn
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
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# To install the latest version, run:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 配置命令别名

```shell
tee ~/.mzzbrc <<EOF
export PATH=~/.local/opt/nodejs/node-v18.17.1-linux-x64/bin:$PATH

alias app='bash app.sh'
alias mcp='mvn clean package'
alias mcc='mvn clean compile'
alias sbr='mvn spring-boot:run'
alias ccr='mcc && sbr'

alias cdp='cd ~/mzzb-project'
alias cdm='cd ~/mzzb-project/soft-mysql'
alias cdr='cd ~/mzzb-project/soft-rabbitmq'
alias cds='cd ~/mzzb-project/mzzb-server'
alias cdu='cd ~/mzzb-project/mzzb-ui'

alias dk='sudo docker'
alias di='sudo docker image'
alias ds='sudo service docker'
EOF
source ~/.mzzbrc
echo "source ~/.mzzbrc" >> ~/.profile
```

### 配置开发代理

```shell
sudo vim /etc/hosts

127.0.0.1       app-soft-mysql
127.0.0.1       app-soft-rabbitmq
127.0.0.1       app-mzzb-server
```

### 获取项目代码

```shell
git clone https://github.com/mingzuozhibi/mzzb-project ~/mzzb-project
```

### 项目初始化

```shell
cd ~/mzzb-project
app setup
```

### 启动与停止

```shell
cd ~/mzzb-project
app start
app stop
```

### 测试与开发

```shell
cd ~/mzzb-project
app dev

cd ~/mzzb-project/mzzb-server
mvn spring-boot:run

cd ~/mzzb-project/mzzb-ui
yarn install
yarn start
```
