#!/bin/bash
# Author: FamaServer (https://famaserver.com)
# GitHub: https://github.com/famaserver
# License: MIT
# Description: Auto-install n8n with Docker on Ubuntu 22/24

echo "🔧 Starting n8n installation..."

read -p "Enter your domain (leave empty to use IP and port 5678): " DOMAIN

mkdir -p /opt/n8n
cd /opt/n8n || exit 1

cat <<EOF > docker-compose.yml
version: "3.7"
services:
  n8n:
    image: n8nio/n8n
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=$(openssl rand -hex 12)
      - N8N_HOST=${DOMAIN:-localhost}
      - WEBHOOK_URL=${DOMAIN:+https://$DOMAIN}
      - N8N_PORT=5678
      - TZ=Europe/Tehran
    volumes:
      - n8n_data:/home/node/.n8n
volumes:
  n8n_data:
EOF

if ! command -v docker &> /dev/null; then
    echo "🔹 Installing Docker..."
    apt update && apt install -y docker.io
fi

if ! command -v docker-compose &> /dev/null; then
    echo "🔹 Installing docker-compose..."
    apt install -y docker-compose
fi

echo "🚀 Launching n8n with docker-compose..."
docker-compose up -d

echo "✅ n8n installed successfully!"
if [[ -n "$DOMAIN" ]]; then
    echo "🌐 Access n8n at: https://$DOMAIN"
else
    IP=$(curl -s ifconfig.me)
    echo "🌐 Access n8n at: http://$IP:5678"
fi
