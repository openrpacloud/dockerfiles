#!/bin/sh

# 路径同步脚本
# 通过环境变量 SOURCE_PATH 和 TARGET_PATH 传入源路径和目标路径
# 如果目标路径存在且有完成标记文件，则跳过同步
# 否则执行同步并创建标记文件

set -e  # 遇到错误立即退出

# 配置项
MARKER_FILE=".sync_completed"  # 完成标记文件名
LOG_FILE="/dev/stdout"  # 日志文件路径

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 错误处理函数
error_exit() {
    log "ERROR: $1"
    exit 1
}

# 检查环境变量
check_env_vars() {
    if [[ -z "$SOURCE_PATH" ]]; then
        error_exit "环境变量 SOURCE_PATH 未设置"
    fi
    
    if [[ -z "$TARGET_PATH" ]]; then
        error_exit "环境变量 TARGET_PATH 未设置"
    fi
    
    log "源路径: $SOURCE_PATH"
    log "目标路径: $TARGET_PATH"
}

# 检查源路径是否存在
check_source_path() {
    if [[ ! -d "$SOURCE_PATH" ]]; then
        error_exit "源路径不存在: $SOURCE_PATH"
    fi
    
    if [[ ! -r "$SOURCE_PATH" ]]; then
        error_exit "源路径无读取权限: $SOURCE_PATH"
    fi
    
    log "源路径检查通过: $SOURCE_PATH"
}

# 检查目标路径状态
check_target_status() {
    # 如果目标路径不存在，返回需要同步
    if [[ ! -d "$TARGET_PATH" ]]; then
        log "目标路径不存在，需要创建并同步"
        return 1
    fi
    
    # 检查完成标记文件
    if [[ -f "$TARGET_PATH/$MARKER_FILE" ]]; then
        log "发现完成标记文件，跳过同步"
        return 0
    else
        log "目标路径存在但无完成标记，需要同步"
        return 1
    fi
}

# 创建目标路径
create_target_dir() {
    if [[ ! -d "$TARGET_PATH" ]]; then
        log "创建目标路径: $TARGET_PATH"
        mkdir -p "$TARGET_PATH" || error_exit "无法创建目标路径: $TARGET_PATH"
    fi
}

# 执行同步
perform_sync() {
    log "开始同步 $SOURCE_PATH -> $TARGET_PATH"
    
    # 使用rsync进行同步，保持权限和时间戳
    if command -v rsync &> /dev/null; then
        rsync -av --delete "$SOURCE_PATH/" "$TARGET_PATH/" || error_exit "rsync同步失败"
        log "rsync同步完成"
    else
        # 如果没有rsync，使用cp作为备选
        log "未找到rsync，使用cp进行同步"
        cp -r "$SOURCE_PATH/"* "$TARGET_PATH/" 2>/dev/null || error_exit "cp同步失败"
        log "cp同步完成"
    fi
}

# 创建完成标记文件
create_marker() {
    local marker_path="$TARGET_PATH/$MARKER_FILE"
    log "创建完成标记文件: $marker_path"
    
    {
        echo "# 同步完成标记文件"
        echo "# 创建时间: $(date)"
        echo "# 源路径: $SOURCE_PATH"
        echo "# 目标路径: $TARGET_PATH"
        echo "# 脚本执行者: $(whoami)"
        echo "# 主机名: $(hostname)"
    } > "$marker_path" || error_exit "无法创建标记文件"
    
    log "标记文件创建成功"
}

# 主函数
main() {
    log "========== 路径同步脚本开始执行 =========="
    
    # 检查环境变量
    check_env_vars
    
    # 检查源路径
    check_source_path
    
    # 检查目标路径状态
    if check_target_status; then
        log "同步已完成，无需重复执行"
        log "========== 脚本执行结束 =========="
        exit 0
    fi
    
    # 创建目标路径
    create_target_dir
    
    # 执行同步
    perform_sync
    
    # 创建完成标记
    create_marker
    
    log "========== 路径同步脚本执行完成 =========="
}

# 脚本入口
main "$@"