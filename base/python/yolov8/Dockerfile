FROM registry.yygu.cn/base/python:torch-2.7

RUN sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources && \
    apt update && \
    apt install -y tzdata libgl1-mesa-glx && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ENV TZ=Asia/Shanghai

RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY Ultralytics /root/.config/

