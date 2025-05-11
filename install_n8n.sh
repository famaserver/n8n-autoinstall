#!/bin/bash

# نمایش لوگوی FamaServer به صورت ASCII
clear
echo -e "\033[1;34m
   ______         ______            ______                 
  / ____/____    / ____/___  ____  / ____/___  ____ ______
 / / __/ ___/   / / __/ __ \/ __ \/ / __/ __ \/ __ \`/ ___/
 \____/ /__    / /_/ /_/ / /_/ / /_/ /_/ /_/ / /_/ / /__  
 /_/    \___/   \____/\____/ .___/ .___/\____/\____/\___/  
                         /_/    /_/                          
\033[0m"
echo -e "\033[1;32m
Installation Script for n8n - FamaServer (c) 2025
\033[0m"

# دریافت دامنه یا IP از کاربر
read -p "Enter your domain or IP (e.g., yourdomain.com or 65.21.118.76): " HOST

# چک کردن که آیا دامنه یا IP وارد شده است
if [ -z "$HOST" ]; then
  echo "Error: You must provide a domain or IP address."
  exit 1
fi

echo -e "\033[1;32mUsing IP/Domain: $HOST\033[0m"

# تولید پسورد رندوم برای دسترسی به N8N
PASSWORD=$(openssl rand -base64 16)

echo -e "\033[1;32mGenerated password: $PASSWORD\033[0m"

# نصب پیش‌نیازها
echo -e "\033[1;32mInstalling required packages...\033[0m"
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl gnupg2 lsb-release ca-certificates docker.io nginx

# راه‌اندازی Docker
echo -e "\033[1;32mStarting Docker service...\033[0m"
sudo systemctl enable docker
sudo systemctl start docker

# دانلود و راه‌اندازی n8n در Docker
echo -e "\033[1;32mSetting up n8n...\033[0m"
sudo docker run -d \
  --name n8n \
  -p 5678:5678 \
  --env N8N_BASIC_AUTH_ACTIVE=true \
  --env N8N_BASIC_AUTH_USER=admin \
  --env N8N_BASIC_AUTH_PASSWORD=$PASSWORD \
  --env N8N_SECURE_COOKIE=false \
  n8nio/n8n

# پیکربندی Nginx برای هدایت به Docker
echo -e "\033[1;32mConfiguring Nginx...\033[0m"
sudo bash -c "cat > /etc/nginx/sites-available/n8n <<EOF
server {
    listen 80;
    server_name $HOST;

    location / {
        proxy_pass http://localhost:5678;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF"

# فعال کردن پیکربندی Nginx
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo nginx -t

# راه‌اندازی مجدد Nginx
echo -e "\033[1;32mRestarting Nginx...\033[0m"
sudo systemctl restart nginx

# نمایش پیام موفقیت
echo -e "\033[1;32mn8n has been successfully installed!\033[0m"
echo -e "\033[1;33mYou can now access n8n via: http://$HOST:5678\033[0m"
echo -e "\033[1;32mInstallation Script by FamaServer (c) 2025\033[0m"

# نمایش اطلاعات ورود
echo -e "\033[1;34mAccess Details:\033[0m"
echo -e "\033[1;32mUsername: admin\033[0m"
echo -e "\033[1;32mPassword: $PASSWORD\033[0m"

# پایان نصب
exit 0
