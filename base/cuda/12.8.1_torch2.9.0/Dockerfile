FROM registry.yygu.cn/library/cuda:12.8.1-cudnn-runtime-ubuntu24.04

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y build-essential python3.12-dev python3-pip
ENV PIP_BREAK_SYSTEM_PACKAGES=1
RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/
RUN pip3 install torch==2.9.0


# RUN wget -O /tmp/flash_attn-2.8.3+cu12torch2.9cxx11abiTRUE-cp312-cp312-linux_x86_64.whl https://mirrors-1369730192.cos.ap-beijing.myqcloud.com/pip/flash_attn/flash_attn-2.8.3%2Bcu12torch2.9cxx11abiTRUE-cp312-cp312-linux_x86_64.whl