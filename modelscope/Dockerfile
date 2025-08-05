# TO registry.yygu.cn/llm-models/download:1.0
FROM registry.yygu.cn/base/python:3.10

RUN pip3 install modelscope -i https://mirrors.aliyun.com/pypi/simple/

COPY download.py /

ENTRYPOINT ["python3", "/download.py"]

ENV MODEL_NAME=baichuan/t5-base
ENV MODEL_SAVE_PATH=/models