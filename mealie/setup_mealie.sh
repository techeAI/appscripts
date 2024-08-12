#!/bin/bash
BASE_DIR=/mnt/DriveDATA
apt install wget curl  sudo -y 2> /dev/null
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

docker run -d --restart unless-stopped --name mealie -p 5009:9000  -v $BASE_DIR/mealie:/app/data/ hkotel/mealie:latest

local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:5009 to access Mealie."
sleep 5
