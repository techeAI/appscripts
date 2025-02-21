#!/bin/bash
#read -p "Enter the URL(Do not add http or https): https://" app_url
apt install wget curl docker-compose sudo -y 2> /dev/null
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
core_secret=$(openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | head -c 16)
Basedir=/mnt/DriveDATA/OnlyOfficeNo443
mkdir $Basedir
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/OnlyOfficeNo443/docker-compose.yaml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/OnlyOfficeNo443/office-nginx.conf -o office-nginx.conf
mv office-nginx.conf /etc/nginx/sites-enabled/office
sed -i "s|Basedir|$Basedir|g" ./docker-compose.yaml
sed -i "s|core_secret|$core_secret|g" ./docker-compose.yaml
docker-compose up -d

sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/office"