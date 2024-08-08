#!/bin/bash
BASE_DIR=/mnt/DriveDATA/myDesktop
apt install sudo curl wget  -y 2> /dev/null

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

if sudo docker ps --format '{{.Names}}' | grep -q "myDESKTOP"; then
echo "The container 'myDESKTOP' is already running. Skipping installation."
sleep 2
else
echo "Setting up myDESKTOP service..."
local_ip=$(ip route get 1 | awk '{print $7}')
sudo mkdir $BASE_DIR
sudo docker run --name=myDESKTOP -p 8201:8080 -v $BASE_DIR/myDESKTOP_config:/config -d --restart unless-stopped oznu/guacamole
sudo docker restart myDESKTOP
echo "!!!!!! ############################################### !!!!!!!"
echo " "
echo "Now you can access your device through URL: http://$local_ip:8201"
sleep 5
fi
