#!/bin/bash
apt install git sudo curl wget  unzip   -y 2> /dev/null
BASE_DIR=/mnt/DriveDATA
mkdir -p $BASE_DIR/vaultwarden
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
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/vaultwarden/vw-nginc.conf -o vw-nginc.conf
mv vw-nginc.conf /etc/nginx/sites-enabled/vw
clear
echo "Admin Panel Secret Key is : $random_string"
echo "Please Note Down Key (It will not be recoverable)"
docker run -dt --name vaultwarden --restart=unless-stopped -v $BASE_DIR/vaultwarden/:/data/ -p 7077:80 vaultwarden/server:1.32.1
local_ip=$(ip route get 1 | awk '{print $7}')
echo "Now you can access vaultwarden through URL: http://$local_ip:7077"
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/vw"