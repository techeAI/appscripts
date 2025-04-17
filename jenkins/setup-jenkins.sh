#!/bin/bash
#read -p "Enter the URL(Do not add http or https): https://" app_url
apt install wget curl docker-compose sudo -y > /dev/null
BASE_DIR=/mnt/DriveDATA/
mkdir -p $BASE_DIR/jenkins
PORT=8221
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
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/jenkins/jenkins-nginx.conf -o jenkins-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/jenkins/docker-compose.yaml -o docker-compose.yaml
mv jenkins-nginx.conf  /etc/nginx/sites-enabled/jenkins
apt install wget curl docker-compose sudo -y > /dev/null
docker compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:$PORT to access."
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/jenkins"