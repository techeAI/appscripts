#!/bin/bash
BASE_DIR=/mnt/DriveDATA/homeassistant
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
 
mkdir -p $BASE_DIR
docker run -d \
  --name homeassistant \
  -p 5006:8123 \
  --restart=unless-stopped \
  -e TZ=Asia/Kolkata \
  -v $BASE_DIR/	CONFIG:/config \
  -v /run/dbus:/run/dbus:ro \
  ghcr.io/home-assistant/home-assistant:stable

local_ip=$(ip route get 1 | awk '{print $7}')
echo "Now you can access Home Assistant through URL: http://$local_ip:5006"
