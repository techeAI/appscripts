#!/bin/bash

# Variables
NGINX_CONF="/etc/nginx/sites-available/default"
EXPORTER_PATH="/usr/local/bin/nginx-prometheus-exporter"
EXPORTER_PORT="8233"
STATUS_PORT="8234"
SYSTEMD_SERVICE="/etc/systemd/system/nginx-exporter.service"

# Step 1: Ensure NGINX is installed
if ! command -v nginx &> /dev/null; then
  echo "❌ NGINX is not installed. Please install it manually."
  exit 1
fi
echo "✅ NGINX is already installed."

# Step 2: Install NGINX Prometheus Exporter if missing
if [ ! -f "$EXPORTER_PATH" ]; then
  echo "📦 Installing NGINX Prometheus Exporter..."
  wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v1.1.0/nginx-prometheus-exporter_1.1.0_linux_amd64.tar.gz
  tar -xvf nginx-prometheus-exporter_1.1.0_linux_amd64.tar.gz
  sudo mv nginx-prometheus-exporter /usr/local/bin/
  rm nginx-prometheus-exporter_1.1.0_linux_amd64.tar.gz
  echo "✅ Exporter installed at $EXPORTER_PATH"
else
  echo "✅ Exporter already present at $EXPORTER_PATH"
fi

# Step 3: Configure NGINX for stub_status on port 8234
echo "🔧 Configuring NGINX stub_status..."

if ! grep -q "listen 127.0.0.1:$STATUS_PORT;" "$NGINX_CONF"; then
  sudo tee -a "$NGINX_CONF" > /dev/null <<EOL

server {
    listen 127.0.0.1:$STATUS_PORT;
    server_name localhost;

    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }
}
EOL
  echo "✅ NGINX status page configured on port $STATUS_PORT"
else
  echo "⚠️ NGINX already has a stub_status block on port $STATUS_PORT"
fi

# Step 4: Reload NGINX
echo "🔄 Reloading NGINX..."
sudo systemctl reload nginx
if [ $? -eq 0 ]; then
  echo "✅ NGINX reloaded successfully."
else
  echo "❌ Failed to reload NGINX."
  exit 1
fi

# Step 5: Create systemd service for exporter
echo "⚙️ Creating systemd service at $SYSTEMD_SERVICE"

sudo tee "$SYSTEMD_SERVICE" > /dev/null <<EOL
[Unit]
Description=NGINX Prometheus Exporter
After=network.target

[Service]
ExecStart=$EXPORTER_PATH \\
  -nginx.scrape-uri=http://localhost:$STATUS_PORT/nginx_status \\
  --web.listen-address=:$EXPORTER_PORT
Restart=always
User=nobody
Group=nogroup

[Install]
WantedBy=multi-user.target
EOL

# Step 6: Reload systemd and start the service
echo "🚀 Enabling and starting nginx-exporter systemd service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable nginx-exporter
sudo systemctl restart nginx-exporter

# Final check
if systemctl is-active --quiet nginx-exporter; then
  echo "✅ NGINX Prometheus Exporter is running on port $EXPORTER_PORT"
else
  echo "❌ Exporter service failed to start. Check logs with: journalctl -u nginx-exporter -f"
  exit 1
fi

echo "🎉 Setup complete!"
echo "• NGINX stub_status: http://localhost:$STATUS_PORT/nginx_status"
echo "• Exporter metrics:  http://localhost:$EXPORTER_PORT/metrics"
