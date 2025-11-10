FROM registry.yygu.cn/library/java:21-jdk
# TO registry.yygu.cn/base/java:21-jdk

RUN apt update && apt install -y maven

COPY ./settings.xml /usr/share/maven/conf/settings.xml

WORKDIR /app