#!/bin/bash
# 设置脚本执行出错终止
set -e

# 显示部署进度的函数
print_section() {
    echo -e "\n\033[1;36m=== $1 ===\033[0m"
}

print_success() {
    echo -e "\033[1;32m√ $1\033[0m"
}

print_error() {
    echo -e "\033[1;31m✗ $1\033[0m"
}

print_warning() {
    echo -e "\033[1;33m! $1\033[0m"
}

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 检查服务并重启函数
check_and_restart_service() {
    local service_name=$1
    local start_command=$2
    local process_pattern=$3

    print_section "检查并启动服务: $service_name"

    # 检查服务是否已运行
    if pgrep -f "$process_pattern" > /dev/null; then
        local pid=$(pgrep -f "$process_pattern")
        print_warning "发现已存在的 $service_name 服务进程 (PID: $pid)，正在停止..."
        kill -15 $pid
        sleep 2

        # 检查进程是否仍在运行，如果是，则强制终止
        if pgrep -f "$process_pattern" > /dev/null; then
            print_warning "$service_name 服务未能优雅停止，正在强制终止..."
            kill -9 $(pgrep -f "$process_pattern")
            sleep 1
        fi

        print_success "$service_name 服务已停止，准备重新启动"
    else
        print_success "未发现运行中的 $service_name 服务，准备启动"
    fi

    # 执行启动命令
    eval "$start_command"
    print_success "$service_name 服务已启动"
}

# 确保日志目录存在
ensure_log_dirs() {
    mkdir -p /app/logs/model
    mkdir -p /app/logs/chat2db-enterprise-gateway
    mkdir -p /app/logs/chat2db-enterprise
    print_success "已创建日志目录"
}

# 加载环境变量
print_section "加载环境变量配置"
# 使用绝对路径查找.env文件
ENV_FILE="${SCRIPT_DIR}/.env"

if [ -f "$ENV_FILE" ]; then
    echo "使用环境变量配置文件: $ENV_FILE"
    # 从.env文件中提取注释的行，并去掉#号
    while IFS= read -r line; do
        # 跳过空行和块注释分隔符行
        if [ -z "$line" ] || echo "$line" | grep -q "^\#\*"; then
            continue
        fi

        # 如果是被注释的变量定义行(以# 开头，后面跟着变量名=值)
        if echo "$line" | grep -q "^\#[[:space:]]*[A-Za-z0-9_]\+="; then
            # 提取变量名
            var_name=$(echo "$line" | sed -E 's/^\#[[:space:]]*([A-Za-z0-9_]+)=.*/\1/')
            # 提取变量值
            var_value=$(echo "$line" | sed -E 's/^\#[[:space:]]*[A-Za-z0-9_]+=(.*)$/\1/')
            # 去掉值两端的引号
            var_value=$(echo "$var_value" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
            # 导出变量
            export "$var_name=$var_value"
            echo "设置环境变量: $var_name=$var_value"
        fi
    done < "$ENV_FILE"
    print_success "成功加载环境变量"
else
    # 尝试在其他常见位置查找.env文件
    ALTERNATE_ENV_FILE="/app/service/.env"
    if [ -f "$ALTERNATE_ENV_FILE" ]; then
        echo "在备选位置找到环境变量配置文件: $ALTERNATE_ENV_FILE"
        # (重复上面的读取逻辑，使用 $ALTERNATE_ENV_FILE)
        while IFS= read -r line; do
            if [ -z "$line" ] || echo "$line" | grep -q "^\#\*"; then
                continue
            fi
            if echo "$line" | grep -q "^\#[[:space:]]*[A-Za-z0-9_]\+="; then
                var_name=$(echo "$line" | sed -E 's/^\#[[:space:]]*([A-Za-z0-9_]+)=.*/\1/')
                var_value=$(echo "$line" | sed -E 's/^\#[[:space:]]*[A-Za-z0-9_]+=(.*)$/\1/')
                var_value=$(echo "$var_value" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
                export "$var_name=$var_value"
                echo "设置环境变量: $var_name=$var_value"
            fi
        done < "$ALTERNATE_ENV_FILE"
        print_success "成功从备选位置加载环境变量"
    else
        # 列出目录内容以帮助调试
        echo "当前目录: $(pwd)"
        echo "脚本目录: $SCRIPT_DIR"
        echo "当前目录内容:"
        ls -la
        echo "脚本目录内容:"
        ls -la "$SCRIPT_DIR"
        echo "/app/service/ 目录内容:"
        if [ -d "/app/service" ]; then
            ls -la /app/service/
        else
            echo "目录 /app/service/ 不存在!"
        fi

        print_error "未找到.env文件，将使用默认设置"
    fi
fi

source ~/.bashrc

# 设置默认值
MODEL_CKPT_DIR=${MODEL_CKPT_DIR:-./model}
APP_JAR_PATH=${APP_JAR_PATH:-./service}
SERVICE_TAR_NAME=${SERVICE_TAR_NAME:-chat2db_0308.tar}
CHAT2DB_SOURCE_IMAGE_NAME=${CHAT2DB_SOURCE_IMAGE_NAME:-chat2db:0308}
CHAT2DB_IMAGE_NAME=${CHAT2DB_IMAGE_NAME:-chat2db:0308}

MYSQL_DATA_DIR=${MYSQL_DATA_DIR:-./mysql-data}
MYSQL_SOURCE_IMAGE_NAME=${MYSQL_SOURCE_IMAGE_NAME:-mysql:chat2db}
MYSQL_IMAGE_NAME=${MYSQL_IMAGE_NAME:-mysql:chat2db}
MYSQL_HOST=${MYSQL_HOST:-127.0.0.1}
MYSQL_PORT=${MYSQL_PORT:-3306}
MYSQL_USER=${MYSQL_USER:-root}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-chat2db}

ES_SOURCE_IMAGE_NAME=${ES_SOURCE_IMAGE_NAME:-elastic:chat2db}
ES_IMAGE_NAME=${ES_IMAGE_NAME:-elastic:chat2db}
ES_USERNAME=${ES_USERNAME:-elastic}
ES_PASSWORD=${ES_PASSWORD:-elastic}
ES_DATA_DIR=${ES_DATA_DIR:-./es-data}
ES_HOST=${ES_HOST:-127.0.0.1}
ES_HTTP_PORT=${ES_HTTP_PORT:-9200}
ES_TRANSPORT_PORT=${ES_TRANSPORT_PORT:-9300}

LICENSE_INFO=${LICENSE_INFO:-""}
CLIENT_DOMAIN_NAME=${CLIENT_DOMAIN_NAME:-http://127.0.0.1:1924}
CHAT2DB_GATEWAY_BASE_URL=${CHAT2DB_GATEWAY_BASE_URL:-http://127.0.0.1:11924}
AI_SOURCE=${AI_SOURCE:-OLLAMAAI}
AI_KEY=${AI_KEY:-CHAT2DB}
MODEL_NAME=${MODEL_NAME:-chat-sql-7B-4bit:latest}
MODEL_EMBED_NAME=${MODEL_EMBED_NAME:-/data/models/bge-m3}
MODEL_CHAT_URL=${MODEL_CHAT_URL:-http://localhost:11434/api/chat}
MODEL_EMBED_URL=${MODEL_EMBED_URL:-http://localhost:11434/api/embed}
SKIP_PYTHON=${SKIP_PYTHON:-false}
SKIP_CLIENT=${SKIP_CLIENT:-false}
SKIPT_GATEWAY=${SKIPT_GATEWAY:-false}

# 打印所有环境变量
print_section "环境变量配置信息"
echo -e "\033[1;33m路径配置:\033[0m"
echo "MODEL_CKPT_DIR = ${MODEL_CKPT_DIR}"
echo "APP_JAR_PATH = ${APP_JAR_PATH}"
echo "SERVICE_TAR_NAME = ${SERVICE_TAR_NAME}"
echo ""

echo -e "\033[1;33mMySQL配置:\033[0m"
echo "MYSQL_DATA_DIR = ${MYSQL_DATA_DIR}"
echo "MYSQL_SOURCE_IMAGE_NAME = ${MYSQL_SOURCE_IMAGE_NAME}"
echo "MYSQL_IMAGE_NAME = ${MYSQL_IMAGE_NAME}"
echo "MYSQL_HOST = ${MYSQL_HOST}"
echo "MYSQL_PORT = ${MYSQL_PORT}"
echo "MYSQL_ROOT_PASSWORD = ${MYSQL_ROOT_PASSWORD}"
echo ""

echo -e "\033[1;33mElasticsearch配置:\033[0m"
echo "ES_SOURCE_IMAGE_NAME = ${ES_SOURCE_IMAGE_NAME}"
echo "ES_IMAGE_NAME = ${ES_IMAGE_NAME}"
echo "ES_USERNAME = ${ES_USERNAME}"
echo "ES_PASSWORD = ${ES_PASSWORD}"
echo "ES_DATA_DIR = ${ES_DATA_DIR}"
echo "ES_HOST = ${ES_HOST}"
echo "ES_HTTP_PORT = ${ES_HTTP_PORT}"
echo "ES_TRANSPORT_PORT = ${ES_TRANSPORT_PORT}"
echo ""

echo -e "\033[1;33m服务配置:\033[0m"
echo "LICENSE_INFO = ${LICENSE_INFO}"
echo "CLIENT_DOMAIN_NAME = ${CLIENT_DOMAIN_NAME}"
echo "CHAT2DB_GATEWAY_BASE_URL = ${CHAT2DB_GATEWAY_BASE_URL}"
echo "MODEL_NAME = ${MODEL_NAME}"

# 确保日志目录存在
ensure_log_dirs

# 构建Java启动命令的参数
java_args="--license.info=${LICENSE_INFO} --spring.datasource.url=\"jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/enterprise_gateway_release?useSSL=false&characterEncoding=utf-8&allowPublicKeyRetrieval=true\" --spring.datasource.username=${MYSQL_USER} --spring.datasource.password=${MYSQL_ROOT_PASSWORD} --excel.datasource.url=\"jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/excel_dev?useSSL=false&characterEncoding=utf-8&allowPublicKeyRetrieval=true\" --excel.datasource.username=${MYSQL_USER} --excel.datasource.password=${MYSQL_ROOT_PASSWORD} --elasticsearch.host=${ES_HOST} --elasticsearch.port=${ES_HTTP_PORT} --elasticsearch.username=${ES_USERNAME} --elasticsearch.password=${ES_PASSWORD} --chat2db.url=${MODEL_CHAT_URL} --chat2db.apiKey=${AI_KEY} --ai.default.model=${MODEL_NAME} --ai.default.embedding.url=${MODEL_EMBED_URL} --use.embedding=false --ai.default.embedding.source=${AI_SOURCE} --ai.sql.source=${AI_SOURCE} --ai.list=${AI_SOURCE} --ai.default.embedding.model=${MODEL_EMBED_NAME}"

# 如果skip_python不为true，则启动Ollama服务
if [ "${SKIP_PYTHON}" != true ] ; then
    check_and_restart_service "Ollama" "ollama serve > /app/logs/model/model.log 2>&1 &" "ollama serve"
fi

# 启动Gateway服务
if [ "${SKIPT_GATEWAY}" != true ] ; then
    gateway_cmd="nohup java --add-opens java.base/java.lang.invoke=ALL-UNNAMED -javaagent:/app/service/chat2db-enterprise-gateway.jar -jar /app/service/chat2db-enterprise-gateway.jar $java_args > /app/logs/chat2db-enterprise-gateway/app.log 2>&1 &"
    check_and_restart_service "Gateway" "$gateway_cmd" "chat2db-enterprise-gateway.jar"
    echo $java_args
fi

# 启动Client服务
client_args="-Dchat2db.gatewayUrl.default=${CHAT2DB_GATEWAY_BASE_URL} -Dchat2db.gatewayUrl.cn=${CHAT2DB_GATEWAY_BASE_URL} -Dchat2db.gatewayUrl.us=${CHAT2DB_GATEWAY_BASE_URL} -Dchat2db.appUrl.default=${CLIENT_DOMAIN_NAME} -Dchat2db.appUrl.cn=${CLIENT_DOMAIN_NAME} -Dchat2db.appUrl.us=${CLIENT_DOMAIN_NAME}"
if [ "${SKIP_CLIENT}" != true ] ; then
    client_cmd="nohup java --add-opens java.base/java.lang.invoke=ALL-UNNAMED -javaagent:/app/service/chat2db-enterprise.jar $client_args -jar /app/service/chat2db-enterprise.jar > /app/logs/chat2db-enterprise/app.log 2>&1 &"
    check_and_restart_service "Client" "$client_cmd" "chat2db-enterprise.jar"
    echo $client_args
fi

# 检查服务运行状态
print_section "检查服务运行状态"
sleep 5

# 检查Ollama服务
if [ "${SKIP_PYTHON}" != true ] && pgrep -f "ollama serve" > /dev/null; then
    print_success "Ollama服务运行中 (PID: $(pgrep -f 'ollama serve'))"
    # 检查端口是否可访问
    if (echo > /dev/tcp/localhost/11434) 2>/dev/null; then
        print_success "Ollama API端口(11434)可访问"
    else
        print_warning "Ollama API端口(11434)不可访问"
    fi
elif [ "${SKIP_PYTHON}" != true ]; then
    print_error "Ollama服务未运行"
fi

sleep 60
# 检查Gateway服务
if [ "${SKIPT_GATEWAY}" != true ] && pgrep -f "chat2db-enterprise-gateway.jar" > /dev/null; then
    print_success "Gateway服务运行中 (PID: $(pgrep -f 'chat2db-enterprise-gateway.jar'))"
elif [ "${SKIPT_GATEWAY}" != true ]; then
    print_error "Gateway服务未运行"
fi

# 检查Client服务
sleep 60
if [ "${SKIP_CLIENT}" != true ] && pgrep -f "chat2db-enterprise.jar" > /dev/null; then
    print_success "Client服务运行中 (PID: $(pgrep -f 'chat2db-enterprise.jar'))"
elif [ "${SKIP_CLIENT}" != true ]; then
    print_error "Client服务未运行"
fi

echo "脚本执行完成，所有服务已启动。服务日志可在 /app/logs/ 目录下查看。"
