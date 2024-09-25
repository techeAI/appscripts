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
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/MantisBT/docker-compose.yml -o docker-compose.yaml

#curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/suitecrm/crm-nginx.conf -o crm-nginx.conf
#mv crm-nginx.conf /etc/nginx/sites-enabled/crm

docker-compose -f ./docker-compose.yaml up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo  "Please access the suiteCRM at http://$local_ip:$port_http"
echo ""
echo ""
sleep 10
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/techebt"
#echo "docker-compose.yaml has been updated with the provided values."
#echo "Directories have been created with appropriate permissions if they did not already exist."