#!/bin/bash
BASE_DIR=/mnt/DriveDATA/openproject
PORT=7079
random_key=$(openssl rand -hex 16)
read -p "Set hostname (without http or https) for openproject : " hname

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
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/openproject/openproject-nginx.conf -o openproject-nginx.conf
sleep 2
sed -i "s|prefixproject.domainname|$hname|g" ./openproject-nginx.conf
mv openproject-nginx.conf /etc/nginx/sites-enabled/openproject
sudo mkdir -p $BASE_DIR/pgdata 
sudo mkdir -p $BASE_DIR/assets
docker run -dt -p $PORT:80 --name openproject --restart unless-stopped \
  -e OPENPROJECT_HOST_NAME=$hname \
  -e OPENPROJECT_SECRET_KEY_BASE=$random_key \
  -v $BASE_DIR/pgdata:/var/openproject/pgdata \
  -v $BASE_DIR/assets:/var/openproject/assets \
  openproject/openproject:14
clear
echo "Generated key: $random_key"
local_ip=$(ip route get 1 | awk '{print $7}')
echo "Now you can access openproject through URL: http://$local_ip:$PORT or https://$hname (after setup ssl) "
