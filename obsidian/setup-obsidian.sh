#!/bin/bash
apt install git sudo curl wget  unzip   -y 2> /dev/null
BASE_DIR=/mnt/DriveDATA/obsidian
mkdir -p $BASE_DIR/config

if [ ! -x /usr/bin/docker ]; then
echo "Installing docker.."
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

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/obsidian/obs-nginx.conf -o obs-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/obsidian/docker-compose.yaml -o docker-compose.yaml
mv obs-nginx.conf /etc/nginx/sites-enabled/obs
docker compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "Now you can access vaultwarden through URL: http://$local_ip:7079"
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/obs"