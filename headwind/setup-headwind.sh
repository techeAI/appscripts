#!/bin/bash

apt install wget curl docker-compose sudo -y 2> /dev/null
mkdir -p /mnt/DriveDATA/headwind/headwind-work
mkdir -p /mnt/DriveDATA/headwind/headwind_db
if [ ! -x /usr/bin/docker ]; then
echo "Installing docker.."
sleep 2
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo setfacl --modify user:$USER:rw /var/run/docker.sock 2> /dev/null
else
echo "Docker is already installed."
sleep 2
fi
read -p "Enter the URL(Do not add http or https): https://" app_url
read -p "Enter Admin Email: https://" adminemail
secret=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 10)

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/headwind/docker-compose.yml -o docker-compose.yml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/headwind/headwind-nginx.conf -o headwind-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/immich/headwind.env -o .env

sed -i "s|changeme-url|$app_url|g" .env
sed -i "s|changeme-email|$adminemail|g" .env
sed -i "s|changeme-secret|$secret|g" .env

mv immich-nginx.conf /etc/nginx/sites-enabled/
docker compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "Secret is $secret"
echo "login http://$local_ip:7086 to access Immich."
sleep 5
