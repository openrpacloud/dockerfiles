# TO registry.yygu.cn/llm-models/rerank-emb:v1.0
# 基础镜像
FROM registry.yygu.cn/base/vllm:openai-v0.8.5-1

# 复制本地模型到容器
COPY ./model /model

# 安装 supervisord（如果基础镜像里没有）
RUN apt-get update && apt-get install -y supervisor && rm -rf /var/lib/apt/lists/*

# 复制 supervisord 配置
COPY supervisord.conf /etc/supervisord.conf

# 暴露端口
EXPOSE 8080 8081

# 启动 supervisord
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
    