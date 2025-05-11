#!/bin/bash
# install_n8n.sh - Auto installer for n8n with domain/IP support
# (c) 2025 FamaServer - https://famaserver.com

set -e

# Prompt for domain or IP
read -p "Enter your domain (or press Enter to use server IP): " DOMAIN

if [ -z "$DOMAIN" ]; then
    DOMAIN=$(curl -s http://checkip.amazonaws.com)
    if [ -z "$DOMAIN" ]; then
        echo "Error: Could not detect server IP. Please specify a domain or IP."
        exit 1
    fi
fi

# Generate random password
PASSWORD=$(openssl rand -base64 12)

# Install Docker & Docker Compose if not installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com | bash
fi

# Install Nginx if not installed
if ! command -v nginx &> /dev/null; then
    echo "Installing Nginx..."
    apt update && apt install -y nginx
fi

# Run n8n container
if [ ! $(docker ps -q -f name=n8n) ]; then
    docker run -d \
        --name n8n \
        -p 5678:5678 \
        --env N8N_BASIC_AUTH_ACTIVE=true \
        --env N8N_BASIC_AUTH_USER=admin \
        --env N8N_BASIC_AUTH_PASSWORD=$PASSWORD \
        --env N8N_HOST=$DOMAIN \
        --env N8N_PORT=5678 \
        --env WEBHOOK_TUNNEL_URL=http://$DOMAIN \
        --env N8N_PROTOCOL=http \
        --env N8N_SECURE_COOKIE=false \
        n8nio/n8n
fi

# Create Nginx config
NGINX_CONF=/etc/nginx/sites-available/n8n

cat > $NGINX_CONF <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

ln -sf $NGINX_CONF /etc/nginx/sites-enabled/n8n
nginx -t && systemctl reload nginx

# Output access info
echo "\n========================================"
echo "✅ n8n نصب شد با موفقیت!"
echo "📍 آدرس: http://$DOMAIN"
echo "👤 یوزرنیم: admin"
echo "🔑 پسورد: $PASSWORD"
echo "========================================"
