FROM registry.yygu.cn/base/cuda:12.4.1

ENV TZ=Asia/Shanghai

RUN apt update && apt install -y build-essential python3.10-dev

RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/
RUN pip3 install vllm
