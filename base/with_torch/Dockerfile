FROM registry.yygu.cn/base/python:3.10

# Debian / Ubuntu
RUN apt-get update && apt-get install -y build-essential python3-dev

COPY requirements.txt /app/requirements.txt

RUN pip uninstall -y PyMuPDF fitz 2>/dev/null || true && \
    pip install --no-cache-dir --force-reinstall PyMuPDF

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fontconfig \
    ttf-wqy-zenhei

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN pip install --no-cache-dir -r /app/requirements.txt

CMD [ "python3" ]


# TO registry.yygu.cn/base/with-torch:v2.8.1
# docker build -f Dockerfile -t registry.yygu.cn/base/with-torch:v2.8.1-amd64 .
