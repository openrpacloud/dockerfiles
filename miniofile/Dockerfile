# To registry.yygu.cn/library/minio-init:v0.1.2
# 基础镜像
FROM registry.yygu.cn/library/ubuntu:22.04

# 设置工作目录
WORKDIR /app

# 把本地 minio 文件夹复制到镜像内
COPY minio /app/scripts/minio

# # 安装 imagemagick（Alpine 用 apk）
# RUN apk add --no-cache imagemagick

# 设置容器启动命令
CMD ["ls", "/app/scripts/minio"]
