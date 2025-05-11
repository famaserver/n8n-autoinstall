#!/bin/bash

# نمایش پیغام ابتدایی
echo "Installing n8n..."

# نصب پیش‌نیازها
sudo apt-get update && sudo apt-get install -y docker.io curl sudo

# راه‌اندازی Docker
sudo systemctl enable --now docker

# دانلود و اجرای n8n با Docker و دور زدن ارور HTTP
sudo docker run -d \
  --name n8n \
  -p 5678:5678 \
  --env N8N_BASIC_AUTH_ACTIVE=true \
  --env N8N_BASIC_AUTH_USER=admin \
  --env N8N_BASIC_AUTH_PASSWORD=$(openssl rand -base64 12) \
  --env N8N_SECURE_COOKIE=false \
  n8nio/n8n

# نمایش آدرس، نام کاربری و پسورد
IP_ADDRESS=$(hostname -I | awk '{print $1}')
PASSWORD=$(docker exec -it n8n printenv N8N_BASIC_AUTH_PASSWORD)

# رنگ سبز برای موفقیت
echo -e "\033[32mInstallation successful!\033[0m"
echo -e "\033[32mAccess n8n at: http://$IP_ADDRESS:5678\033[0m"
echo -e "\033[32mUsername: admin\033[0m"
echo -e "\033[32mPassword: $PASSWORD\033[0m"
