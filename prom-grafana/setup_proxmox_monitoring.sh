#!/bin/bash

set -e

echo "=== Proxmox Monitoring Setup (Node Exporter + PVE Exporter) ==="

# Prompt for API token details
read -p "Enter your Proxmox API token name (e.g., root@pam!prometheus): " PVE_TOKEN_NAME
read -s -p "Enter your Proxmox API token secret: " PVE_TOKEN_SECRET
echo ""

echo "=== Installing dependencies ==="
apt update
apt install -y python3-pip python3-venv pipx lm-sensors smartmontools curl wget tar

echo "=== Initializing pipx ==="
/usr/bin/pipx ensurepath
export PATH=$PATH:/root/.local/bin

echo "=== Creating /etc/prometheus/pve.yml ==="
mkdir -p /etc/prometheus
cat <<EOF > /etc/prometheus/pve.yml
default:
  token_name: ${PVE_TOKEN_NAME}
  token_value: ${PVE_TOKEN_SECRET}
  verify_ssl: false
  base_url: https://localhost:8006/api2/json
EOF
chmod 600 /etc/prometheus/pve.yml

echo "=== Installing prometheus-pve-exporter via pipx ==="
pipx install prometheus-pve-exporter

echo "=== Creating systemd service for prometheus-pve-exporter ==="
cat <<EOF > /etc/systemd/system/pve-exporter.service
[Unit]
Description=Prometheus Proxmox Exporter
After=network.target

[Service]
ExecStart=/root/.local/bin/prometheus-pve-exporter --config /etc/prometheus/pve.yml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "=== Enabling and starting prometheus-pve-exporter ==="
systemctl daemon-reexec
systemctl enable --now pve-exporter

echo "=== Running sensors-detect (auto mode) ==="
yes | sensors-detect --auto

echo "=== Installing node_exporter ==="
useradd --no-create-home --shell /usr/sbin/nologin node_exporter || true

cd /opt
NODE_EXPORTER_VERSION="1.8.1"
wget https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
tar xvf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
cp node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter /usr/local/bin/

echo "=== Creating systemd service for node_exporter ==="
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=default.target
EOF

echo "=== Enabling and starting node_exporter ==="
systemctl daemon-reexec
systemctl enable --now node_exporter

echo "✅ Setup complete!"
echo "🔹 Proxmox exporter: http://<this-host>:9221/metrics"
echo "🔹 Node exporter:    http://<this-host>:9100/metrics"
