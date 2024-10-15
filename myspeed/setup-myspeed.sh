#!/bin/bash
BASE_DIR=/mnt/DriveDATA/
PORT=7081
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
mkdir -p $BASE_DIR/myspeed
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/myspeed/myspeed-nginx.conf -o myspeed-nginx.conf
sleep 2
mv myspeed-nginx.conf /etc/nginx/sites-enabled/myspeed
sleep 2
docker run -dt --name myspeed --restart unless-stopped -p $PORT:5216 -v $BASE_DIR/myspeed:/myspeed/data germannewsmaker/myspeed:1.0.9

local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "After install SSL - login http://$local_ip:$PORT to access on URL."
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/myspeed"