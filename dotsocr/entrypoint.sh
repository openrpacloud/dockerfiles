#!/bin/sh
set -e

ROUTINE_NUM=${ROUTINE_NUM:-1}
SUPERVISOR_CONF=/etc/supervisord.conf
HAPROXY_CONF=/etc/haproxy/haproxy.cfg

cat > "$SUPERVISOR_CONF" <<EOF
[supervisord]
nodaemon=true
EOF

# 写 haproxy 配置
cat > "$HAPROXY_CONF" <<EOF
global
    log stdout format raw local0

defaults
    log global
    mode tcp
    timeout connect 5s
    timeout client  30m
    timeout server  30m

frontend f_merged
    bind *:8080
    default_backend b_models

backend b_models
    balance roundrobin
EOF

for i in $(seq 1 $ROUTINE_NUM); do
cat >> "$SUPERVISOR_CONF" <<EOF
[program:vllm_${i}]
directory=/models/rednote-hilab/
command=vllm serve ./DotsOCR --port 808${i} --tensor-parallel-size 1 --gpu-memory-utilization 0.92  --chat-template-content-format string --served-model-name DotsOCR --trust-remote-code
autostart=true
autorestart=true
environment=TMPDIR="/tmp/pdfium_${i}s"
stdout_logfile_maxbytes=0
stderr_logfile_maxbytes=0
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr
EOF

# 给 haproxy backend 加 target
echo "    server s${i} 127.0.0.1:808${i} check" >> "$HAPROXY_CONF"

done

# 再把 haproxy 加入 supervisord
cat >> "$SUPERVISOR_CONF" <<EOF
[program:haproxy]
command=haproxy -f $HAPROXY_CONF -db
autostart=true
autorestart=true
stdout_logfile_maxbytes=0
stderr_logfile_maxbytes=0
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr
EOF

exec supervisord -c "$SUPERVISOR_CONF"
