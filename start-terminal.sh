#!/bin/bash
set -e

# 密码
USER_PASSWORD="${HF_USER_PASSWORD:-Sealos123}"

# Cloudflare Token
CLOUDFLARE_TOKEN="${HF_CLOUDFLARE_TOKEN:-}"

echo "[init] Using ttyd password: $USER_PASSWORD"

# 启动 ttyd
if [ -f "/app/index.html" ]; then
    /usr/local/bin/ttyd -p 7860 --index /app/index.html --credential "admin:$USER_PASSWORD" bash &
    TT_PID=$!
else
    /usr/local/bin/ttyd -p 7860 --credential "admin:$USER_PASSWORD" bash &
    TT_PID=$!
fi

# 启动 Cloudflare Tunnel（可选）
if [ -n "$CLOUDFLARE_TOKEN" ]; then
    echo "[init] Starting Cloudflare Tunnel..."
    /usr/local/bin/cloudflared tunnel run --token "$CLOUDFLARE_TOKEN" &
    CF_PID=$!
else
    echo "[init] HF_CLOUDFLARE_TOKEN not set. Skipping Cloudflare Tunnel."
fi

# 启动 tmate
/usr/bin/tmate &
TM_PID=$!

# 等待所有已定义的后台进程
PIDS=($TT_PID)
[ -n "${CF_PID:-}" ] && PIDS+=($CF_PID)
[ -n "${TM_PID:-}" ] && PIDS+=($TM_PID)

echo "[init] Waiting for processes: ${PIDS[*]}"
wait "${PIDS[@]}"
