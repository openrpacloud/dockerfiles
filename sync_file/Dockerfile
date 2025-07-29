FROM registry.yygu.cn/library/alpine:3

RUN apk --no-cache add rsync

COPY entrypoint.sh /

ENTRYPOINT /entrypoint.sh

# ENV SOURCE_PATH=/a
# ENV TARGET_PATH=/b