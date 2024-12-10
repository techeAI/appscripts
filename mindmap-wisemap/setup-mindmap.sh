#!/bin/bash
#read -p "Enter the URL(Do not add http or https): https://" app_url
apt install wget curl docker-compose sudo -y > /dev/null
BASE_DIR=/mnt/DriveDATA/
mkdir -p $BASE_DIR/mindmap
PORT=7087
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
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mindmap-wisemap/mindmap-nginx.conf -o mindmap-nginx.conf
mv mindmap-nginx.conf  /etc/nginx/sites-enabled/mindmap

docker run -dt --restart unless-stopped --name mindmap-wisemap -p $PORT:8080 -v $BASE_DIR/mindmap:/var/lib/wise-db wisemapping/wisemapping:latest

docker cp mindmap-wisemap:/var/lib/wisemapping/db $BASE_DIR/mindmap/
docker rm -f mindmap-wisemap
docker run -dt --restart unless-stopped --name mindmap-wisemap -p $PORT:8080 -v $BASE_DIR/mindmap:/var/lib/wisemapping/db wisemapping/wisemapping:latest

local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:$PORT to access."
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/mindmap"