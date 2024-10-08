#!/bin/bash
read -p "Enter the URL: " app_url
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
mkdir -p /mnt/DriveDATA/bookstack/
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/bookstack/docker-compose.yaml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/bookstack/bs-nginx.conf -o bs-nginx.conf
mv bs-nginx.conf /etc/nginx/sites-enabled/bs

sed -i "s|ChangeMe-APP_URL|$app_url|g" ./docker-compose.yaml && docker-compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:7076 to access bookstack."
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/bs"