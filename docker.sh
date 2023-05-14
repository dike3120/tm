#!/bin/bash

# Check if Docker and Docker Compose are already installed
if ! command -v docker >/dev/null 2>&1 || ! command -v docker-compose >/dev/null 2>&1 ; then
  # Install Docker
  curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh

  # Install Docker Compose
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.17.1/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

# Create directory 'tm' if it doesn't exist
mkdir -p /root/tm

# Get public IP address
ip=$(curl -sS ip.sb)

# Get region name based on IP address
region=$(curl -sS "https://ipapi.co/$ip/region")

# Create 'docker-compose.yml' file for tm
cat <<EOF > /root/tm/docker-compose.yml
version: "3"
services:
  tm:
    image: traffmonetizer/cli
    command: start accept --token doGDCYUFVBFyxldQaoH3zTc2+0S2MdcRZ7IzRUO4x7w= --device-name aws-32v-2-$region
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
