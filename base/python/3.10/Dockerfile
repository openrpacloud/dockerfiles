FROM python:3.10
# FROM registry.yygu.cn/base/python:3.10

ENV TZ=Asia/Shanghai
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/

RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
RUN sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources && \
    apt update && \
    apt install -y tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

