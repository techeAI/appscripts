#!/bin/bash
url=$(grep "^headscale_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
apt install git docker-compose sudo curl wget  unzip   -y 2> /dev/null
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
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/akaunting/docker-compose.yaml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/akaunting/akaunting-nginx.conf -o akaunting-nginx.conf
sed -i "s|prefixaccounts.domainname|$url|g" ./akaunting-nginx.conf
mv akaunting-nginx.conf /etc/nginx/sites-available/akaunting
ln -s /etc/nginx/sites-available/akaunting /etc/nginx/sites-enabled/akaunting
docker-compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "Now you can access Akaunting through URL: http://$local_ip:7070" 
echo ""
echo ""
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/akaunting"