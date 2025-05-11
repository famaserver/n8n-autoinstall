#!/bin/bash

# نصب پیش‌نیازها
echo "Installing dependencies..."
sudo apt update -y
sudo apt install -y curl docker.io docker-compose nginx

# فعال‌سازی و شروع Docker
echo "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# دانلود و راه‌اندازی کانتینر n8n
echo "Setting up n8n container..."
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -e N8N_HOST=localhost \
  -e N8N_PORT=5678 \
  -e N8N_PROTOCOL=http \
  -e N8N_BASIC_AUTH_ACTIVE=false \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n

# تنظیمات nginx برای دسترسی HTTP
echo "Configuring Nginx..."
sudo bash -c 'cat > /etc/nginx/sites-available/n8n <<EOF
server {
    listen 80;
    server_name $1;  # دامنه وارد شده توسط کاربر

    location / {
        proxy_pass http://127.0.0.1:5678;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF'

# فعال‌سازی پیکربندی Nginx
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# پیکربندی امنیتی برای جلوگیری از ارور secure cookie
echo "Configuring secure cookie settings..."
sudo bash -c 'cat >> ~/.bashrc <<EOF
export N8N_SECURE_COOKIE=false
EOF'

# راه‌اندازی دوباره Nginx
sudo systemctl restart nginx

echo "n8n is installed successfully. Access it via http://<your_ip_or_domain>:5678"
