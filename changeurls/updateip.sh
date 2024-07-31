#!/bin/bash
IP=$(hostname -I | awk '{print $1}')
sed -i "s/yourip/$IP/g" /etc/OT/DASHBOARD/teche-dashboard_configs/default.json
echo "Updated IPs for local access in dashboard."
