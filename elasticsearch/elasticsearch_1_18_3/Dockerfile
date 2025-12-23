# TO registry.yygu.cn/base/elasticsearch:8.18.1-3
FROM registry.yygu.cn/base/elasticsearch:8.18.1-2


COPY IKAnalyzer.cfg.xml \
 /usr/share/elasticsearch/config/analysis-ik/

COPY new_words.dic \
 /usr/share/elasticsearch/config/analysis-ik/


# docker manifest create registry.yygu.cn/base/elasticsearch:8.18.1-3 \
#   registry.yygu.cn/base/elasticsearch:8.18.1-3-amd64 \
#   registry.yygu.cn/base/elasticsearch:8.18.1-3-arm64


# docker manifest annotate registry.yygu.cn/base/elasticsearch:8.18.1-3 \
#   registry.yygu.cn/base/elasticsearch:8.18.1-3-amd64 --arch amd64 --os linux

# docker manifest annotate registry.yygu.cn/base/elasticsearch:8.18.1-3 \
#    registry.yygu.cn/base/elasticsearch:8.18.1-3-arm64 --arch arm64 --os linux

# docker manifest push registry.yygu.cn/base/elasticsearch:8.18.1-3
