#!/bin/bash

echo -e "\033[1;32m
███████╗ █████╗ ███╗   ███╗ █████╗
██╔════╝██╔══██╗████╗ ████║██╔══██╗
█████╗  ███████║██╔████╔██║███████║
██╔══╝  ██╔══██║██║╚██╔╝██║██╔══██║
██║     ██║  ██║██║ ╚═╝ ██║██║  ██║
╚═╝     ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝
\033[0m"
echo -e "\033[1;32mInstallation Script for n8n - FamaServer.com (c) 2025\033[0m"

# Ask for domain or IP
read -p "Enter your domain (e.g. yourdomain.com) or IP address (e.g. 192.168.1.1): " server_address

# Check if domain/IP is empty
if [ -z "$server_address" ]; then
  echo "Error: You must provide a domain or IP address."
  exit 1
fi

# If domain is provided, append http:// to it, if IP is provided, leave it as is
if [[ "$server_address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Using IP address: http://$server_address"
  n8n_url="http://$server_address"
else
  echo "Using domain: http://$server_address"
  n8n_url="http://$server_address"
fi

# Installing required dependencies
echo "Installing required dependencies..."
sudo apt update
sudo apt install -y docker.io curl

# Pull the n8n Docker image
echo "Pulling the n8n Docker image..."
sudo docker pull n8nio/n8n

# Run the n8n container
echo "Running n8n container..."
sudo docker run -d \
  --name n8n \
  -p 5678:5678 \
  --env N8N_BASIC_AUTH_ACTIVE=true \
  --env N8N_BASIC_AUTH_USER=admin \
  --env N8N_BASIC_AUTH_PASSWORD=$(openssl rand -base64 12) \
  n8nio/n8n

# Provide success message with credentials
echo "n8n installation completed!"
echo "You can access n8n at: $n8n_url:5678"
echo "Login using the following credentials:"
echo "Username: admin"
echo "Password: $(openssl rand -base64 12)"
