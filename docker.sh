#!/bin/bash

# 检查是否已安装 Docker
if ! command -v docker >/dev/null 2>&1 ; then
    # 安装 Docker
    curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
fi

# 检查是否已安装 Docker Compose
if ! command -v docker-compose >/dev/null 2>&1 ; then
    # 获取 CPU 架构
    cpu_arch=$(uname -m)

    # 根据 CPU 架构定义 Docker Compose 的发布 URL
    compose_url=""
    if [ "$cpu_arch" == "x86_64" ]; then
        compose_url="https://github.com/docker/compose/releases/download/v2.17.1/docker-compose-linux-x86_64"
    elif [ "$cpu_arch" == "aarch64" ]; then
        compose_url="https://github.com/docker/compose/releases/download/v2.17.1/docker-compose-linux-arm64"
    fi

    # 安装 Docker Compose
    if [ -n "$compose_url" ]; then
        sudo curl -L "$compose_url" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo "不支持的 CPU 架构: $cpu_arch"
        exit 1
    fi
fi

# 如果目录 'tm' 不存在，则创建
mkdir -p /root/tm

# 获取公网 IP 地址
ip=$(curl -sS ip.cn/s)

# 根据 IP 地址获取地区名称
region=$(curl -sS "https://ip.cn/index.php?ip=$ip&action=2" | grep -oP '(?<=来自：).*?(?=\s)')

# 获取 CPU 架构
cpu_arch=$(uname -m)

# 为 tm 创建 'docker-compose.yml' 文件
cat <<EOF > /root/tm/docker-compose.yml
version: "3"
services:
  tm:
    image: traffmonetizer/cli
    command: start accept --token doGDCYUFVBFyxldQaoH3zTc2+0S2MdcRZ7IzRUO4x7w= --device-name $region-$cpu_arch-$ip
    container_name: tm
    restart: always
EOF

# 启动 tm 容器
cd /root/tm && docker-compose up -d

# 如果目录 'peer2' 不存在，则创建
mkdir -p /root/peer2

# 为 peer2pro 创建 'docker-compose.yml' 文件
cat <<EOF > /root/peer2/docker-compose.yml
version: '3'
services:
  peer2pro:
    image: peer2profit/peer2profit_linux:latest
    restart: always
    environment:
      - P2P_EMAIL=dike3120@hotmail.com
    container_name: peer2pro
EOF

# 启动 peer2pro 容器
cd /root/peer2 && docker-compose up -d
