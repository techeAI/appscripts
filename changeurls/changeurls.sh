#!/bin/bash
echo "Please provide your domain name (like: example.com)"
read dname
sed -i "s/openteche.io/$dname/g" /etc/OT/DASHBOARD/teche-dashboard_configs/default.json
echo "All URLs have been updated"
sudo docker restart teche-dashboard
