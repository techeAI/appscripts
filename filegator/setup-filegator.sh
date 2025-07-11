#!/bin/bash
url=$(grep "^filegator_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
BASE_DIR=/mnt/DriveDATA
PORT=7090
apt install wget curl sudo -y 2> /dev/null
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

if sudo docker ps --format '{{.Names}}' | grep -q "filgator"; then
                                echo "The container 'filgator' is already running. Skipping installation."
                                sleep 2
                        else
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/filegator/filegator-nginx.conf -o filegator-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/filegator/docker-compose.yaml -o docker-compose.yaml
#curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/filegator/configuration.php -o configuration.php
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/filegator/user.json -o users.json
sudo mkdir -p $BASE_DIR/filegator/files &&  sudo mkdir -p $BASE_DIR/filegator/users/ && mkdir -p $BASE_DIR/filegator/config
sed -i "s|prefixvault.domainname|$url|g" ./filegator-nginx.conf
mv filegator-nginx.conf /etc/nginx/sites-available/filegator
ln -s /etc/nginx/sites-available/filegator /etc/nginx/sites-enabled/filegator
#mv configuration.php $BASE_DIR/filegator/config/configuration.php
mv users.json $BASE_DIR/filegator/users/users.json
sudo chown -R www-data:www-data $BASE_DIR/filegator/
                                echo "Setting up filegator.."

sleep 2
docker compose up -d
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/filegator"
fi