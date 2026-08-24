# To registry.yygu.cn/chat2db/chat2db-enterprise:0.1.0
FROM registry.yygu.cn/chat2db/chat2db-enterprise:base-0.1.0

WORKDIR /app/service

# 复制 service 目录
COPY service/ /app/service/

# 复制宿主机当前目录下的 jdbc-lib 到容器的 ~/.qdata 目录
COPY jdbc-lib /root/.qdata/jdbc-lib

# 确保 entrypoint 可执行
RUN chmod +x /app/service/entrypoint.sh

ENV ENV_FILE=/app/service/.env

EXPOSE 11924 1924

CMD ["/bin/bash", "-c", "/app/service/entrypoint.sh"]
