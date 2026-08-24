# To registry.yygu.cn/library/ms-playwright:v0.0.1
# 指定基础镜像
FROM registry.yygu.cn/library/alpine:3.22.0

# 设置工作目录（可选）
WORKDIR /opt/playwright

# 拷贝浏览器二进制
COPY ms-playwright /opt/playwright/ms-playwright

# 拷贝 Go 可执行文件
COPY ms-playwright-go /opt/playwright/ms-playwright-go


# 如果 ms-playwright-go 下有可执行文件，需要赋予权限
RUN chmod -R +x /opt/playwright/ms-playwright-go


