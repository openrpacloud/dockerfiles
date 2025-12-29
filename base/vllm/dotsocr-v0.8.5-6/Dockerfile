# TO registry.yygu.cn/base/vllm:dotsocr-v0.8.5
FROM registry.yygu.cn/base/vllm:openai-v0.8.5

ENV TZ=Asia/Shanghai
ENV PYTHONPATH=/models/:$PYTHONPATH
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
RUN pip install flash-attn

RUN sed -i '/^from vllm\.entrypoints\.cli\.main import main$/a\
from DotsOCR import modeling_dots_ocr_vllm' `which vllm`

RUN pip install supervisor && apt install -y haproxy

VOLUME [ "/models/" ]

ENV ROUTINE_NUM=1

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
