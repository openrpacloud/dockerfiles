#!/bin/bash

# 输出日志时带上时间戳
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 确保脚本可执行
log "设置脚本权限..."
chmod +x /app/service/service_start.sh
chmod +x /app/service/monitor_services.sh

# 确保日志目录存在
log "创建日志目录..."
mkdir -p /app/logs
chmod -R 755 /app/logs

# 设置cron任务
log "设置服务监控定时任务..."
echo "* * * * * /bin/bash /app/service/monitor_services.sh" > /etc/cron.d/service-monitor
chmod 0644 /etc/cron.d/service-monitor
crontab /etc/cron.d/service-monitor

# 启动cron服务
log "启动cron服务..."
service cron start || crond

# 立即启动应用服务
log "启动应用服务..."
/bin/bash /app/service/service_start.sh

# 保持容器运行
log "初始化完成，容器将持续运行..."
tail -f /dev/null
