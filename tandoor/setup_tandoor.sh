#!/bin/bash

apt install wget docker-compose curl  sudo -y 2> /dev/null
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


curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/tandoor/.env -o .env
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/tandoor/docker-compose.yaml -o docker-compose.yaml
docker-compose up -d

local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:5005 to access Tandoor."
sleep 5