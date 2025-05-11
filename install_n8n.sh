#!/bin/bash
# n8n Auto Installer with Optional Domain and SSL Support
# Maintained by FamaServer (https://famaserver.com)
# GitHub: https://github.com/famaserver/n8n-installer

set -e

# رنگ‌ها
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# سوال دامنه
read -p "Enter your domain (or leave blank to use server IP): " DOMAIN

# تنظیم اطلاعات لاگین
N8N_BASIC_AUTH_USER="admin"
N8N_BASIC_AUTH_PASSWORD=$(openssl rand -hex 12)

# نصب Docker و Docker Compose
echo -e "${GREEN}Installing Docker and Docker Compose...${NC}"
apt update -y
apt install -y docker.io docker-compose
systemctl enable --now docker

# ساخت پوشه برای n8n
mkdir -p /opt/n8n && cd /opt/n8n

# ساخت فایل env
cat <<EOF > .env
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=${N8N_BASIC_AUTH_USER}
N8N_BASIC_AUTH_PASSWORD=${N8N_BASIC_AUTH_PASSWORD}
N8N_HOST=${DOMAIN:-$(hostname -I | awk '{print $1}')}
N8N_PORT=5678
EOF

# اگر کاربر دامنه وارد کرد، SSL فعال شود
if [[ -n "$DOMAIN" ]]; then
  echo -e "${GREEN}Domain detected. Configuring with HTTPS...${NC}"

  docker run -d \
    --name n8n \
    --restart always \
    -p 127.0.0.1:5678:5678 \
    --env-file .env \
    -v ~/.n8n:/home/node/.n8n \
    n8nio/n8n

  # نصب nginx و certbot
  apt install -y nginx certbot python3-certbot-nginx

  # ساخت کانفیگ nginx
  cat <<EOF > /etc/nginx/sites-available/n8n
server {
    listen 80;
    server_name ${DOMAIN};

    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

  ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/n8n
  nginx -t && systemctl reload nginx

  # دریافت گواهی SSL
  certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

else
  echo -e "${RED}No domain provided. Configuring without SSL...${NC}"
  echo "N8N_SECURE_COOKIE=false" >> .env

  docker run -d \
    --name n8n \
    --restart always \
    -p 5678:5678 \
    --env-file .env \
    -v ~/.n8n:/home/node/.n8n \
    n8nio/n8n
fi

# نمایش اطلاعات نهایی
PUBLIC_URL="https://${DOMAIN}"
if [[ -z "$DOMAIN" ]]; then
  PUBLIC_URL="http://$(hostname -I | awk '{print $1}'):5678"
fi

echo -e "\n${GREEN}n8n is now installed and running.${NC}"
echo -e "${GREEN}URL: ${PUBLIC_URL}${NC}"
echo -e "${GREEN}Username: ${N8N_BASIC_AUTH_USER}${NC}"
echo -e "${GREEN}Password: ${N8N_BASIC_AUTH_PASSWORD}${NC}"
