FROM rabbitmq:3.12-management
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata
WORKDIR /opt/app
