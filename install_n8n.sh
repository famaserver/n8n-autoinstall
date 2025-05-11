#!/bin/bash

read -rp "Enter your domain (e.g. example.com) or IP address (e.g. 1.2.3.4): " server_address

if [[ -z "$server_address" ]]; then
  echo "Error: You must provide a domain or IP address."
  exit 1
fi

# تولید پسورد رندوم
admin_password=$(openssl rand -hex 12)

# نصب Docker اگر نصب نیست
if ! command -v docker &> /dev/null; then
  apt update && apt install -y curl
  curl -fsSL https://get.docker.com | sh
fi

# ساخت دایرکتوری داده n8n
mkdir -p /root/n8n/.n8n

# اجرای کانتینر n8n
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -v /root/n8n/.n8n:/home/node/.n8n \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD="$admin_password" \
  -e N8N_HOST="$server_address" \
  -e N8N_PORT=5678 \
  -e N8N_PROTOCOL=http \
  -e N8N_SECURE_COOKIE=false \
  --restart unless-stopped \
  n8nio/n8n

echo ""
echo "✅ n8n installation completed!"
echo "🔗 Access URL: http://$server_address:5678"
echo "👤 Username: admin"
echo "🔒 Password: $admin_password"
echo ""
echo "📦 FamaServer.com (c) 2025 - All rights reserved"
