#!/bin/bash
# Variables
REMOTE_USER="root"          # Replace with your remote server's username
REMOTE_HOST="dash.teche.ai"     # Replace with your remote server's IP or hostname
PEM_KEY="/home/admin/key/teche.ai"           # Path to your PEM key
NEW_IP=$(hostname -I | awk '{print $1}')
#find /etc/nginx/sites-enabled/ -type f ! -name "file1.conf" ! -name "file2.conf" -exec sed -i 's/$OLD_IP/$NEW_IP/g' {} +
REMOTE_COMMAND2="grep -m1 -oP 'proxy_pass http://\K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' /etc/nginx/sites-enabled/dashboard"
# Run command on remote server
OLD_IP=$(ssh -i "$PEM_KEY" -o StrictHostKeyChecking=no "$REMOTE_USER@$REMOTE_HOST" "$REMOTE_COMMAND2")
REMOTE_COMMAND1="find /etc/nginx/sites-enabled/ -type f ! -name 'office' -exec sed -i 's/$OLD_IP/$NEW_IP/g' {} + && systemctl restart nginx"
sleep 10
echo "old IP- $OLD_IP"
echo "New IP- $NEW_IP"
ssh -i "$PEM_KEY" -o StrictHostKeyChecking=no "$REMOTE_USER@$REMOTE_HOST" "$REMOTE_COMMAND1"
