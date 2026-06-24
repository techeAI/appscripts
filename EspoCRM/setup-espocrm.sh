#!/bin/bash
url=$(grep "^espo_crm=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
apt install git sudo curl wget  unzip   -y 2> /dev/null
BASE_DIR=/mnt/DriveDATA/espocrm
mkdir -p $BASE_DIR/{db,data}
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
#read -p "Enter URL to access on browser (without http/https)(ex. erpnext.teche.ai): " url
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/EspoCRM/espocrm-nginx.conf -o espocrm-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/EspoCRM/docker-compose.yaml -o docker-compose.yaml
sed -i "s|changemeurl|$url|g" ./espocrm-nginx.conf
mv espocrm-nginx.conf /etc/nginx/sites-available/espocrm
ln -s /etc/nginx/sites-available/espocrm /etc/nginx/sites-enabled/espocrm
docker compose up -d
#local_ip=$(ip route get 1 | awk '{print $7}')
#echo "Now you can access tunnel through URL: https://$url"
#sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/espocrm"