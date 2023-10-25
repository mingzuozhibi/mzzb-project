FROM mysql:8.0-debian
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata
WORKDIR /opt/app
