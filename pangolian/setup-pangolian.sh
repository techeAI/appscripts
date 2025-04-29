#!/bin/bash
apt install git sudo curl wget  unzip   -y 2> /dev/null
BASE_DIR=/mnt/DriveDATA/pangolin
mkdir -p $BASE_DIR/config
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
read -p "Enter URL to access on browser (without http/https)(ex. proxy.teche.ai): " url
read -p "Enter Base Domain Name (ex. teche.ai): " domainname
read -p "Enter Admin UserName (ex. admin@teche.ai) : " username
read -p "Enter Admin Password (ex. Password123!!) : " password
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/pangolian/pangolian-nginx.conf -o pangolian-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/pangolian/pangolian-config.yml -o pangolian-config.yml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/pangolian/docker-compose.yaml -o docker-compose.yaml
sed -i "s|Changeme-url|$url|g" pangolian-config.yml
sed -i "s|Changeme-url|$url|g" pangolian-nginx.conf
sed -i "s|Chaneme-basedomain|$domainname|g" pangolian-config.yml
sed -i "s|Chaneme-username|$username|g" pangolian-config.yml
sed -i "s|Chaneme-password|$password|g" pangolian-config.yml
mv pangolian-nginx.conf /etc/nginx/sites-available/pangolian
ln -s /etc/nginx/sites-available/pangolian /etc/nginx/sites-enabled/pangolian
mv pangolian-config.yml $BASE_DIR/config/config.yml
docker compose up -d
#local_ip=$(ip route get 1 | awk '{print $7}')
#echo "Now you can access tunnel through URL: https://$url"
#sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/pangolian"