#!/bin/bash
read -p "Enter the URL(Do not add http or https): https://" app_url
BASE_DIR=/mnt/DriveDATA/discourse
PORT=7080
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
mkdir -p $BASE_DIR/postgresql_data
mkdir -p $BASE_DIR/redis_data
mkdir -p $BASE_DIR/discourse_data
mkdir -p $BASE_DIR/sidekiq_data
#echo "Generating Random App Key"
#random_key=$(openssl rand -hex 16)
#echo "Generated key: $random_key"
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/discourse/docker-compose.yaml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/discourse/discourse-nginx.conf -o discourse-nginx.conf
sleep 2
sed -i "s|ChangeMe-APP_URL|$app_url|g" ./docker-compose.yaml 
sed -i "s|ChangeMe-APP_URL|$app_url|g" ./discourse-nginx.conf
mv discourse-nginx.conf /etc/nginx/sites-enabled/discourse
sleep 2
docker-compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:$PORT to access on URL."
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/discourse"