FROM nginx:stable
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata
COPY etc/nginx.conf /etc/nginx
COPY etc/p3000.conf /etc/nginx/conf.d
WORKDIR /opt/app
