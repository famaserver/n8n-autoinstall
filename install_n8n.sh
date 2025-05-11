#!/bin/bash

# Function to ask for domain or IP
ask_domain() {
    read -p "Please enter your domain or IP (e.g., example.com or your_ip): " domain_or_ip
    if [[ -z "$domain_or_ip" ]]; then
        echo "You must enter a domain or IP address."
        exit 1
    fi
}

# Update system and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl gnupg2 lsb-release ca-certificates

# Install Node.js (n8n dependency)
echo "Installing Node.js..."
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# Install Docker (Optional but recommended for n8n)
echo "Installing Docker..."
sudo apt install -y docker.io
sudo systemctl enable --now docker

# Install n8n
echo "Installing n8n..."
sudo npm install -g n8n

# Ask for domain or IP
ask_domain

# Set up n8n as a systemd service
echo "Setting up n8n as a systemd service..."
sudo bash -c 'cat > /etc/systemd/system/n8n.service <<EOF
[Unit]
Description=n8n - Workflow Automation Tool
After=network.target

[Service]
ExecStart=/usr/bin/n8n
Restart=always
User=root
Environment="N8N_BASIC_AUTH_ACTIVE=true"
Environment="N8N_BASIC_AUTH_USER=admin"
Environment="N8N_BASIC_AUTH_PASSWORD=password"
Environment="N8N_HOST='"$domain_or_ip"'"
Environment="N8N_PORT=5678"
Environment="N8N_PROTOCOL=http"
Environment="N8N_SECURITY_COOKIE=true"

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd to pick up the new service and start n8n
echo "Reloading systemd and starting n8n..."
sudo systemctl daemon-reload
sudo systemctl start n8n
sudo systemctl enable n8n

# Install Nginx for reverse proxy
echo "Installing Nginx and setting up reverse proxy..."
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Configure Nginx to reverse proxy n8n
sudo bash -c 'cat > /etc/nginx/sites-available/n8n <<EOF
server {
    listen 80;
    server_name '"$domain_or_ip"';

    location / {
        proxy_pass http://127.0.0.1:5678;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF'

# Enable the Nginx site and restart Nginx
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Inform the user
echo "n8n installation completed successfully!"
echo "You can access n8n at http://$domain_or_ip:5678"
echo "Installation Script by FamaServer (c) 2025"
