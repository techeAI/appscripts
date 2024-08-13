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
 

docker run -d --name vaultwarden --restart=unless-stopped -v $BASE_DIR/vaultwarden/:/data/ -p 5007:80 vaultwarden/server:latest

local_ip=$(ip route get 1 | awk '{print $7}')
echo "Now you can access vaultwarden through URL: http://$local_ip:5007"
