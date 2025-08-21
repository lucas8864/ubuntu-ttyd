#!/bin/bash
set -e

# 如果 HF_USER_PASSWORD 为空，使用默认密码
USER_PASSWORD="${HF_USER_PASSWORD:-Sealos123}"

# 如果 HF_CLOUDFLARE_TOKEN 为空，跳过启动 Cloudflare Tunnel
CLOUDFLARE_TOKEN="$HF_CLOUDFLARE_TOKEN"

echo "Using ttyd password: $USER_PASSWORD"

# 启动 ttyd 后台
if [ -f "/app/index.html" ]; then
    /usr/local/bin/ttyd -p 7860 --index /app/index.html --credential "admin:$USER_PASSWORD" bash &
    TT_PID=$!
else
    /usr/local/bin/ttyd -p 7860 --credential "admin:$USER_PASSWORD" bash &
    TT_PID=$!
fi

# 启动 Cloudflare Tunnel（仅当 TOKEN 存在）
if [ -n "$CLOUDFLARE_TOKEN" ]; then
    echo "Starting Cloudflare Tunnel..."
    cloudflared tunnel run --token "$CLOUDFLARE_TOKEN" &
    CF_PID=$!
else
    echo "HF_CLOUDFLARE_TOKEN not set. Skipping Cloudflare Tunnel."
fi

#启动tmate
/usr/bin/tmate &
TM_PID=$!

# 等待三个进程，tini 作为 PID 1 转发信号
wait $TT_PID $CF_PID $TM_PID
