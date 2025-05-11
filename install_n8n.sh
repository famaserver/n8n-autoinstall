#!/bin/bash

# رنگ‌بندی برای نمایش بهتر پیام‌ها
NC='\033[0m'           # رنگ برای نمایش معمولی
RED='\033[0;31m'       # رنگ قرمز
GREEN='\033[0;32m'     # رنگ سبز
YELLOW='\033[0;33m'    # رنگ زرد

echo -e "${GREEN}Starting n8n Installation...${NC}"

# بررسی دسترسی روت
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root.${NC}"
    exit
fi

# نصب پیش‌نیازها
echo -e "${YELLOW}Installing dependencies...${NC}"
sudo apt update -y
sudo apt install -y curl docker.io docker-compose nginx

# فعال‌سازی و شروع Docker
echo -e "${YELLOW}Enabling and starting Docker...${NC}"
sudo systemctl enable docker
sudo systemctl start docker

# دانلود و راه‌اندازی کانتینر n8n
echo -e "${YELLOW}Setting up n8n container...${NC}"
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -e N8N_HOST=localhost \
  -e N8N_PORT=5678 \
  -e N8N_PROTOCOL=http \
  -e N8N_BASIC_AUTH_ACTIVE=false \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n

# راه‌اندازی Nginx برای دسترسی به n8n
echo -e "${YELLOW}Setting up Nginx...${NC}"
cat <<EOL | sudo tee /etc/nginx/sites-available/n8n
server {
    listen 80;

    server_name ${1:-localhost};  # اگر دامنه داده نشد، از localhost استفاده می‌کند

    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# فعال کردن سایت در Nginx
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/

# راه‌اندازی مجدد سرویس Nginx
echo -e "${YELLOW}Restarting Nginx...${NC}"
sudo systemctl restart nginx

# نمایش آدرس دسترسیی
echo -e "${GREEN}n8n installed successfully! Access it via http://<your_ip_or_domain>:5678${NC}"

# کپی‌رایت
echo -e "${YELLOW}Installation Script by FamaServer (c) 2025${NC}"
