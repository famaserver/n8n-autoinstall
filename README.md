# n8n Auto Installer for Ubuntu 22/24

**Created by [FamaServer](https://famaserver.com) | GitHub: [famaserver](https://github.com/famaserver)**  
**Website:** https://famaserver.com | [Our VPS Plans](https://famaserver.com/vps)

This script installs [n8n](https://n8n.io) on a fresh Ubuntu 22.04 or 24.04 server using Docker.


---

## ⚙️ Features

- Fully automatic installation via one command
- Asks for your domain name (optional)
- Falls back to IP if no domain is given
- Uses Docker and Docker Compose
- Automatically generates secure admin credentials
- Sets timezone to `Asia/Tehran`

---

## 🖥️ Supported Systems

- Ubuntu 22.04 LTS
- Ubuntu 24.04 LTS

---

## 🚀 How to Use

### With Domain:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/famaserver/n8n-autoinstall/main/install_n8n.sh)

After install:
http://YOUR_SERVER_IP:5678
http://YOUR_DOMIN:5678
---
Default Login:
Username: admin

Password: Generated automatically (check Docker logs):

docker-compose logs n8n
---
