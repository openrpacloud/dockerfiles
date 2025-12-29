FROM registry.yygu.cn/base/cuda:12.8.1_torch2.9.0

RUN pip3 install vllm==0.13.0 supervisor

RUN apt update && apt install -y haproxy wget
RUN wget -O /tmp/flash_attn-2.8.3+cu12torch2.9cxx11abiTRUE-cp312-cp312-linux_x86_64.whl https://mirrors-1369730192.cos.ap-beijing.myqcloud.com/pip/flash_attn/flash_attn-2.8.3%2Bcu12torch2.9cxx11abiTRUE-cp312-cp312-linux_x86_64.whl && \
    pip3 install /tmp/flash_attn-2.8.3+cu12torch2.9cxx11abiTRUE-cp312-cp312-linux_x86_64.whl && \
    rm /tmp/flash_attn-2.8.3+cu12torch2.9cxx11abiTRUE-cp312-cp312-linux_x86_64.whl

