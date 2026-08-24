# TO registry.yygu.cn/base/elasticsearch:8.18.1-1
FROM registry.yygu.cn/library/elasticsearch:8.18.1

ENV IK_VERSION=8.18.1

# 安装 IK 分词器插件
RUN cd /usr/share/elasticsearch/bin && \
    ./elasticsearch-plugin install --batch https://get.infini.cloud/elasticsearch/analysis-ik/${IK_VERSION}


