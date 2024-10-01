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
mkdir -p $BASE_DIR/html
mkdir -p $BASE_DIR/db
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/HRMS/hrms-nginx.conf -o hrms-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/HRMS/HRMS.zip -o HRMS.zip
mv hrms-nginx.conf /etc/nginx/sites-enabled/hrms
docker-compose -f ./docker-compose.yaml up -d
mv techebt-2.26.3.zip $BASE_DIR/html/
cd $BASE_DIR/html/ && unzip techebt-2.26.3.zip
chown -R www-data:www-data $BASE_DIR/html/
local_ip=$(ip route get 1 | awk '{print $7}')
echo  "Please access the Bug Tracket at http://$local_ip:$port_http"
echo ""
echo ""
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/techebt"