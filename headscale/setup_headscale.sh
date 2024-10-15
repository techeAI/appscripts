#!/bin/bash
read -p "Enter Full URL without (http/https) for headscale nginx:https:// " url
apt install git sudo curl wget  unzip   -y 2> /dev/null
BASE_DIR=/mnt/DriveDATA
mkdir -p $BASE_DIR/headscale/config
mkdir -p $BASE_DIR/headscale/data
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
echo 'admin:$apr1$1c5irjel$R9IM.YR8walQ0.2KqZ8e30' | sudo tee -a /etc/nginx/.htpasswd
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/headscale/docker-compose.yml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/headscale/headscale-nginx.conf -o headscale-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/headscale/config.yaml -o config.yaml
sleep 2
sed -i "s|domainname_changeme|$url|g" ./config.yaml
sed -i "s|domainname_changeme|$url|g" ./headscale-nginx.conf
mv headscale-nginx.conf /etc/nginx/sites-enabled/headscale
mv config.yaml $BASE_DIR/headscale/config/
sleep 1
docker-compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
sleep 5
echo "To Run Behind nginx proxy please update SSL cert"
echo "Will be accessible at https://$url"