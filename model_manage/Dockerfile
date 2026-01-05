# TO registry.yygu.cn/llm-models/download:1.0
# TO registry.yygu.cn/llm-models/download:1.2
FROM registry.yygu.cn/base/python:3.10

RUN pip3 install tqdm -i https://mirrors.aliyun.com/pypi/simple/
RUN pip3 install loguru -i https://mirrors.aliyun.com/pypi/simple/
RUN pip3 install cos-python-sdk-v5 -i https://mirrors.aliyun.com/pypi/simple/

COPY download.py /

ENTRYPOINT ["python3", "/download.py"]

ENV MODEL_NAME=model_test/20251018/models
ENV MODEL_SAVE_PATH=/data/tmp