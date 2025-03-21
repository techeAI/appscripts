#!/bin/bash
read -p "Enter the URL(Do not add http or https): https://" app_url
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
mkdir -p /mnt/DriveDATA/mattermost/
#echo "Generating Random App Key"
#random_key=$(openssl rand -hex 16)
#echo "Generated key: $random_key"
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mattermost/docker-compose.yaml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mattermost/mattermost-nginx.conf -o mattermost-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mattermost/mattermost.env -o mattermost.env

mv mattermost-nginx.conf /etc/nginx/sites-enabled/mattermost
mv mattermost.env .env
sed -i "s|ChangeMe-APP_URL|$app_url|g" ./.env


sleep 2
docker-compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:8217 to access mattermost."
sleep 5
#echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/mattermost"