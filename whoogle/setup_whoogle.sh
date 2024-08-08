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
docker run --restart unless-stopped --publish 5004:5000 --detach --name whoogle-search benbusby/whoogle-search:latest
local_ip=$(ip route get 1 | awk '{print $7}')
echo "Now you can access ipscanner through URL: http://$local_ip:5004"
