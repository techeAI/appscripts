#!/bin/bash
apt install wget curl sudo -y 2> /dev/null
BASE_DIR=/mnt/DriveDATA/mantis
port_http=3001
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
apt install docker-compose -y
mkdir -p $BASE_DIR/html/config
mkdir -p $BASE_DIR/html/custom
mkdir -p $BASE_DIR/lib/mysql
chown www-data:www-data $BASE_DIR/html/config
chown www-data:www-data $BASE_DIR/html/custom
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/MantisBT/docker-compose.yaml -o docker-compose.yaml

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/MantisBT/techebt-nginx.conf -o techebt-nginx.conf
mv techebt-nginx.conf /etc/nginx/sites-enabled/techebt

docker-compose -f ./docker-compose.yaml up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo  "Please access the Bug Tracket at http://$local_ip:$port_http"
echo ""
echo ""
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/techebt"