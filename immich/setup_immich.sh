#!/bin/bash

apt install wget curl docker-compose sudo -y 2> /dev/null
url=$(grep "^immich_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
mkdir -p /mnt/DriveDATA/immich/immich_server
mkdir -p /mnt/DriveDATA/immich/immich_server_db
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


curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/immich/docker-compose.yml -o docker-compose.yml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/immich/immich-nginx.conf -o immich-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/immich/.env -o .env
sed -i "s|prefixphoto.domainname|$url|g" ./immich-nginx.conf
mv immich-nginx.conf /etc/nginx/sites-available/immich
ln -s /etc/nginx/sites-available/immich /etc/nginx/sites-enabled/immich
docker compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:7086 to access Immich."
sleep 5
