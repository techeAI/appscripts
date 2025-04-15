#!/bin/bash
apt install wget curl sudo -y 2> /dev/null
BASE_DIR=/mnt/DriveDATA/hrms
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
mkdir -p $BASE_DIR
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/HRMS/hrms-nginx.conf -o hrms-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/HRMS/HRMS.zip -o HRMS.zip
mv hrms-nginx.conf /etc/nginx/sites-enabled/hrms
unzip HRMS.zip
cd HRMS && docker-compose -f ./docker-compose.yaml up -d
chown -R www-data:www-data $BASE_DIR
local_ip=$(ip route get 1 | awk '{print $7}')
#echo  "Please access the HRMS at http://$local_ip:7072"
echo ""
echo ""
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/hrms"