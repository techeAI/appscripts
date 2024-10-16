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
mkdir -p /mnt/DriveDATA/meshcentral/data
mkdir -p /mnt/DriveDATA/meshcentral/user_files
mkdir -p /mnt/DriveDATA/meshcentral/backups
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mesh-central/docker-compose.yaml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mesh-central/meshcentral-nginx.conf -o meshcentral-nginx.conf
sleep 2
sed -i "s|ChangeMe-APP_URL|$app_url|g" ./docker-compose.yaml
sed -i "s|ChangeMe-APP_URL|$app_url|g" ./meshcentral-nginx.conf
mv meshcentral-nginx.conf /etc/nginx/sites-enabled/meshcentral
sleep 2
docker-compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "After installing SSL open http://$app_url to access on URL."