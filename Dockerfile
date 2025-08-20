FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/laalucas/ubuntu.git"

ENV TZ=Asia/Shanghai \
    PORT=7860 \
    user=sealos
    DEBIAN_FRONTEND=noninteractive

# 安装依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tzdata ca-certificates curl wget vim unzip net-tools iproute2 iputils-ping telnet lsb-release pciutils neofetch \
    htop tree tmux dnsutils lsof sysstat ncdu rsync bash-completion software-properties-common && \
    update-ca-certificates && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 创建普通用户 ${user}，保证 /etc/passwd 有条目
RUN useradd -m -s /bin/bash ${user} && \
    echo "${user}:x:1000:1000:${user}:/home/${user}:/bin/bash" >> /etc/passwd

WORKDIR /usr/local/bin

# 下载 ttyd 、启动脚本和clouflared,并赋权
RUN curl -L -o ttyd https://github.com/laalucas-us/ubuntu/raw/refs/heads/main/ttyd && \
    curl -L -o start-terminal.sh https://raw.githubusercontent.com/laalucas-us/ubuntu/refs/heads/main/start-terminal.sh && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x ttyd start-terminal.sh cloudflared && \
    mkdir -p /app && chown -R ${user}:${user} /app

WORKDIR /app

# 下载可选自定义首页
RUN curl -L -o index.html https://raw.githubusercontent.com/laalucas-us/ubuntu/refs/heads/main/index.html

EXPOSE ${PORT}

USER ${user}

CMD ["start-terminal.sh"]