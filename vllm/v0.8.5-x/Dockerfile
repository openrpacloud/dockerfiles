# TO registry.yygu.cn/base/vllm:openai-v0.8.5-1
FROM registry.yygu.cn/base/vllm:openai-v0.8.5

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
RUN pip install supervisor
