#!/bin/bash
read -p "Enter the URL(Do not add http or https): https://" app_url
apt install wget curl docker-compose sudo -y > /dev/null
if [ ! -x /usr/bin/docker ]; then
echo "Installing docker.."
sleep 2
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo setfacl --modify user:$USER:rw /var/run/docker.sock > /dev/null
else
echo "Docker is already installed."
sleep 2
fi
mkdir -p /mnt/DriveDATA/chatwoot/
#echo "Generating Random App Key"
#random_key=$(openssl rand -hex 16)
#echo "Generated key: $random_key"
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/chatwoot/docker-compose.yaml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/chatwoot/chatwoot-nginx.conf -o chatwoot-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/chatwoot/env -o env
sleep 2
sed -i "s|ChangeMe-APP_URL|$app_url|g" ./env
sed -i "s|ChangeMe-APP_URL|$app_url|g" ./chatwoot-nginx.conf
mv chatwoot-nginx.conf /etc/nginx/sites-enabled/chatwoot
mv env .env
sleep 2
docker compose run --rm rails bundle exec rails db:chatwoot_prepare
sleep 5
docker-compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "After install SSL open https://$app_url to access on web."
