#!/bin/bash
url=$(grep "^paperless_ngx_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
apt install git sudo curl wget  unzip   -y 2> /dev/null
BASE_DIR=/mnt/DriveDATA/paperless-ngx
mkdir -p $BASE_DIR/data
mkdir -p $BASE_DIR/media
mkdir -p $BASE_DIR/dbdata
mkdir -p $BASE_DIR/redisdata
mkdir -p $BASE_DIR/export
mkdir -p $BASE_DIR/consume

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
#read -p "Enter Full URL with (http or https) for paperless nginx: " url
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/paperless-ngx/ngx-nginx.conf -o ngx-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/paperless-ngx/docker-compose.env -o docker-compose.env
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/paperless-ngx/docker-compose.yaml -o docker-compose.yaml
sed -i "s|PLACEHOLDER_URL|$url|g" docker-compose.env
sed -i "s|prefixdocs.domainname|$url|g" ./ngx-nginx.conf
mv ngx-nginx.conf /etc/nginx/sites-available/ngx
ln -s /etc/nginx/sites-available/ngx /etc/nginx/sites-enabled/ngx
docker compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "Now you can access papperless through URL: $url"
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/ngx"