# TO registry.yygu.cn/base/with-torch:v2.2.0-amd64
FROM registry.yygu.cn/base/python:3.10.14-amd64

# Debian / Ubuntu
RUN apt-get update && apt-get install -y build-essential python3-dev

COPY /data/cjc/yygu/dotpen-doc_analyser_api_gpu/requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir -r /app/requirements.txt

CMD [ "python3" ]
