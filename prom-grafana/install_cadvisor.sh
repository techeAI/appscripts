#!/bin/bash

set -e

VERSION="v0.52.1"
BIN_URL="https://github.com/google/cadvisor/releases/download/${VERSION}/cadvisor-${VERSION}-linux-amd64"
BIN_PATH="/usr/local/bin/cadvisor"
SERVICE_FILE="/etc/systemd/system/cadvisor.service"
PORT=8231

echo "📦 Downloading cAdvisor ${VERSION}..."
wget -q --show-progress "$BIN_URL" -O cadvisor
chmod +x cadvisor

echo "🚚 Moving binary to ${BIN_PATH}..."
sudo mv cadvisor "$BIN_PATH"

echo "🛠️ Creating systemd service (port ${PORT})..."
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=cAdvisor Service
After=network.target

[Service]
ExecStart=${BIN_PATH} -port=${PORT}
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "🔁 Reloading systemd and starting cAdvisor..."
sudo systemctl daemon-reload
sudo systemctl enable --now cadvisor

echo "✅ cAdvisor is now running on http://<your-ip>:${PORT}"