#!/bin/bash

# 输出时间戳的日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> /app/logs/monitor.log
}

# 检查服务是否运行
check_service() {
    local service_name=$1
    local process_pattern=$2

    if ! pgrep -f "$process_pattern" > /dev/null; then
        log "警告: $service_name 服务未运行，正在重启所有服务..."
        return 1
    fi
    return 0
}

# 初始化日志目录
mkdir -p /app/logs

log "开始检查服务状态..."

# 检查三个服务是否运行
ollama_running=true
gateway_running=true
client_running=true

# 检查Gateway服务
if ! check_service "Gateway" "chat2db-enterprise-gateway.jar"; then
    gateway_running=false
fi

# 检查Client服务
if ! check_service "Client" "chat2db-enterprise.jar"; then
    client_running=false
fi

# 如果有任何服务未运行，重启所有服务
if [ "$ollama_running" = false ] || [ "$gateway_running" = false ] || [ "$client_running" = false ]; then
    log "检测到服务异常，执行重启脚本..."
    bash /app/service/service_start.sh >> /app/logs/monitor.log 2>&1
    log "服务重启完成"
else
    log "所有服务正常运行"
fi
