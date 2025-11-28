# TO registry.yygu.cn/base/elasticsearch:8.18.1-2
FROM registry.yygu.cn/library/elasticsearch:8.18.1

ENV IK_VERSION=8.18.1

# 安装 IK 分词器和 smartcn 插件
RUN cd /usr/share/elasticsearch/bin && \
    ./elasticsearch-plugin install --batch https://get.infini.cloud/elasticsearch/analysis-ik/${IK_VERSION} && \
    ./elasticsearch-plugin install --batch analysis-smartcn

docker manifest create registry.yygu.cn/base/elasticsearch:8.18.1-2 \
  registry.yygu.cn/base/elasticsearch:8.18.1-2-amd64 \
  registry.yygu.cn/base/elasticsearch:8.18.1-2-arm64


docker manifest annotate registry.yygu.cn/base/elasticsearch:8.18.1-2 \
  registry.yygu.cn/base/elasticsearch:8.18.1-2-amd64 --arch amd64 --os linux

docker manifest annotate registry.yygu.cn/base/elasticsearch:8.18.1-2 \
   registry.yygu.cn/base/elasticsearch:8.18.1-2-arm64 --arch arm64 --os linux

docker manifest push registry.yygu.cn/base/elasticsearch:8.18.1-2
