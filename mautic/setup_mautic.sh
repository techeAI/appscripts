#!/bin/bash
apt install wget curl docker-compose sudo -y 2> /dev/null
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
sudo mkdir /mnt/DriveDATA/mautic
sudo chmod 777 /mnt/DriveDATA/mautic
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mautic/docker-compose.yaml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mautic/mautic-nginx.conf -o mautic-nginx.conf
mv mautic-nginx.conf /etc/nginx/sites-enabled/mautic
docker-compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:7073 to access mautic."
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/mautic"