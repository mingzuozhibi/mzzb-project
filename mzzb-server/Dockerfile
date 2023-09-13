FROM eclipse-temurin:17
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata
WORKDIR /opt/app
CMD ["java", "-jar", "app.jar"]
