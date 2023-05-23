#!/bin/bash

# Check if Docker is already installed
if ! command -v docker >/dev/null 2>&1 ; then
    # Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
fi

# Check if Docker Compose is already installed
if ! command -v docker-compose >/dev/null 2>&1 ; then
    # Get CPU architecture
    cpu_arch=$(uname -m)

    # Define Docker Compose release URL based on CPU architecture
    compose_url=""
    if [ "$cpu_arch" == "x86_64" ]; then
        compose_url="https://github.com/docker/compose/releases/download/v2.17.1/docker-compose-linux-x86_64"
    elif [ "$cpu_arch" == "aarch64" ]; then
        compose_url="https://github.com/docker/compose/releases/download/v2.17.1/docker-compose-linux-aarch64"
    fi

    # Install Docker Compose
    if [ -n "$compose_url" ]; then
        sudo curl -L "$compose_url" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo "Unsupported CPU architecture: $cpu_arch"
        exit 1
    fi
fi

# Create directory 'tm' if it doesn't exist
mkdir -p /root/tm

# Get public IP address
ip=$(curl -sS ip.sb)

# Get region name based on IP address
region=$(curl -sS "https://ipapi.co/$ip/region/?lang=zh-cn")

# Get CPU architecture
cpu_arch=$(uname -m)

# Create 'docker-compose.yml' file for tm
cat <<EOF > /root/tm/docker-compose.yml
version: "3"
services:
  tm:
    image: traffmonetizer/cli
    command: start accept --token doGDCYUFVBFyxldQaoH3zTc2+0S2MdcRZ7IzRUO4x7w= --device-name $region-$cpu_arch-$ip
    container_name: tm
    restart: always
EOF

# Run tm container
cd /root/tm && docker-compose up -d

# Create directory 'peer2' if it doesn't exist
mkdir -p /root/peer2

# Create 'docker-compose.yml' file for peer2pro
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

# Run peer2pro container
cd /root/peer2 && docker-compose up -d
