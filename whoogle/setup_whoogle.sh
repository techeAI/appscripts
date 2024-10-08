#!/bin/bash
apt install git sudo curl wget  unzip   -y 2> /dev/null
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
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/whoogle/search-nginx.conf -o search-nginx.conf
mv search-nginx.conf /etc/nginx/sites-enabled/search
docker run -dt --restart unless-stopped --publish 7075:5000 -e WHOOGLE_USER=admin -e WHOOGLE_PASS=admin --name whoogle-search benbusby/whoogle-search:0.9.0
local_ip=$(ip route get 1 | awk '{print $7}')
echo "Now you can access search through URL: http://$local_ip:7075"
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/search"
