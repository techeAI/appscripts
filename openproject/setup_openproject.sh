#!/bin/bash
BASE_DIR=/mnt/DriveDATA/openproject
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
sudo mkdir $BASE_DIR/pgdata $BASE_DIR/assets
docker run -d -p 9222:80 --name openproject --restart unless-stopped \
  -e OPENPROJECT_HOST__NAME=openproject.openteche.io \
  -e OPENPROJECT_SECRET_KEY_BASE=secret \
  -v $BASE_DIR/pgdata:/var/openproject/pgdata \
  -v $BASE_DIR/assets:/var/openproject/assets \
  openproject/openproject:14
  
  
local_ip=$(ip route get 1 | awk '{print $7}')
echo "Now you can access ipscanner through URL: http://$local_ip:9222"
