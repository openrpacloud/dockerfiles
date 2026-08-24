# MattePro 后端基础环境镜像（CUDA 13.0.3 版）
# 构建完成后推送到 registry.yygu.cn/base/cuda:13.0.3-cudnn-devel-torch2.10.0
#
# 构建命令（在 backend 目录下执行）：
#   docker build -t registry.yygu.cn/base/cuda:13.0.3-cudnn-devel-torch2.10.0 -f Dockerfile .
#
# 说明：
#   1. 基础镜像为纯 CUDA devel（ubuntu24.04），不含 Python/torch，需自行安装。
#   2. CUDA 13.0.3 对应 torch 2.10.0 + torchvision 0.25.0（cu130）。
#   3. 镜像包含全部推理运行时依赖（torch + detectron2 + 各 Python 包）。
#   4. torch/nvidia 大包按体积拆分为独立层，利用 Docker build 并发拉取，
#      且缓存命中后改业务依赖不重下大包。

FROM registry.yygu.cn/library/cuda:13.0.3-cudnn-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 配置 apt 阿里云镜像源（替换 ubuntu 源为阿里云，加速 apt 下载）
# 兼容 deb822 格式(.sources，ubuntu24.04 默认) 与经典格式(.list)
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.aliyun.com@g; s@//security.ubuntu.com@//mirrors.aliyun.com@g; s@//ports.ubuntu.com@//mirrors.aliyun.com@g' /etc/apt/sources.list.d/*.sources /etc/apt/sources.list.d/*.list /etc/apt/sources.list 2>/dev/null || true

# 安装 Python 3.10 及编译工具链（detectron2 原生算子编译需要 g++/build-essential）
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# 配置 pip 阿里云镜像源（PyPI 包走国内镜像，加速下载；需在上述 python3-pip 安装之后）
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    && pip config set global.trusted-host mirrors.aliyun.com

# ==================== 核心包：torch / torchvision ====================

# torch 本体（~873MB，最重，靠后独立缓存；nvidia 依赖已在上方装好，pip 会识别为已满足、不重复下载）
RUN pip install --no-cache-dir --break-system-packages \
    torch==2.10.0 torchvision==0.25.0 \
    --index-url https://download.pytorch.org/whl/cu130
