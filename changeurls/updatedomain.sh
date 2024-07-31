#!/bin/bash
# Prompt the user to enter their domain
echo "Please enter your domain , like example.com :"
read USER_DOMAIN

# Replace the placeholder with the user's domain
sed -i "s/your.domain/$USER_DOMAIN/g" /etc/OT/DASHBOARD/teche-dashboard_configs/public.json

echo "Domain replacement completed."
