#!/bin/bash
url=$(grep "^mantisBT_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
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
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/MantisBT/docker-compose.yaml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/MantisBT/techebt-nginx.conf -o techebt-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/MantisBT/techebt-2.26.3.zip -o techebt-2.26.3.zip
sed -i "s|prefixbugs.domainname|$url|g" ./techebt-nginx.conf
mv techebt-nginx.conf /etc/nginx/sites-available/techebt
ln -s /etc/nginx/sites-available/techebt /etc/nginx/sites-enabled/techebt
docker-compose -f ./docker-compose.yaml up -d
mv techebt-2.26.3.zip $BASE_DIR/html/
cd $BASE_DIR/html/ && unzip techebt-2.26.3.zip
chown -R www-data:www-data $BASE_DIR/html/
local_ip=$(ip route get 1 | awk '{print $7}')
echo  "Please access the Bug Tracket at http://$local_ip:$port_http"
echo ""
echo ""
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/techebt"