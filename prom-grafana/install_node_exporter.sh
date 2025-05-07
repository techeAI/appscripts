#!/bin/bash
# This is script to run on remote machine to install node exporter for prometheus
# Define version
NODE_EXPORTER_VERSION="1.8.1"

echo "📦 Downloading Node Exporter v$NODE_EXPORTER_VERSION..."
cd /tmp || exit
wget -q https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz

if [ $? -ne 0 ]; then
    echo "❌ Failed to download Node Exporter. Check version and internet connection."
    exit 1
fi

echo "📂 Extracting..."
tar -xzf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
cd node_exporter-$NODE_EXPORTER_VERSION.linux-amd64 || exit

echo "📁 Moving binary to /usr/local/bin..."
sudo cp node_exporter /usr/local/bin/
sudo chown root:root /usr/local/bin/node_exporter

echo "👤 Creating user 'node_exporter'..."
sudo useradd -rs /bin/false node_exporter 2>/dev/null

echo "📝 Creating systemd service..."
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

echo "🔁 Reloading systemd and starting Node Exporter..."
sudo systemctl daemon-reexec
sudo systemctl enable --now node_exporter

echo "✅ Node Exporter is running!"
echo "📊 Metrics available at: http://$(hostname -I | awk '{print $1}'):9100/metrics"