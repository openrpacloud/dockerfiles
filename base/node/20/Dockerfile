FROM node:20
# TO registry.cn-beijing.aliyuncs.com/wa/dev:node_20

MAINTAINER Chuanjian Wang <me@ckeyer.com>

# 设置 node 阿里镜像
# RUN npm config set registry https://registry.npm.taobao.org
# 设置--max-old-space-size
# ENV NODE_OPTIONS=--max-old-space-size=16384
# 设置阿里镜像、pnpm、依赖、编译
RUN npm install -g npm

RUN yarn global add esbuild vite pnpm
