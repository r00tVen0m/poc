#!/bin/bash

set -e

echo "[*] Updating system..."
sudo apt update

echo "[*] Installing required packages..."
sudo apt install -y ca-certificates curl gnupg lsb-release

echo "[*] Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "[*] Adding Docker repository..."

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

echo "[*] Installing Docker..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[*] Enabling Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "[*] Creating Vaultwarden data directory..."
sudo mkdir -p /opt/vaultwarden/data

echo "[*] Removing old Vaultwarden container (if exists)..."
sudo docker stop vaultwarden 2>/dev/null || true
sudo docker rm vaultwarden 2>/dev/null || true

ADMIN_TOKEN="ChangeThisToAVeryStrongRandomPassword"

echo "[*] Starting Vaultwarden..."

sudo docker run -d \
  --name vaultwarden \
  --restart unless-stopped \
  -e WEBSOCKET_ENABLED=true \
  -e SIGNUPS_ALLOWED=false \
  -e ADMIN_TOKEN="$ADMIN_TOKEN" \
  -v /opt/vaultwarden/data:/data \
  -p 8080:80 \
  -p 3012:3012 \
  vaultwarden/vaultwarden:latest

echo
echo "=============================================="
echo "Vaultwarden installed successfully."
echo
echo "Web Interface:"
echo "http://SERVER-IP:8080"
echo
echo "Admin Panel:"
echo "http://SERVER-IP:8080/admin"
echo
echo "Registration: Disabled"
echo
echo "Admin Token:"
echo "$ADMIN_TOKEN"
echo "=============================================="
