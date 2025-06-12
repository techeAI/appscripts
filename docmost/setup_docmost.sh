#!/bin/bash
#read -p "Enter Full URL (without http or https) for docmost:- https://" url
url=$(grep "^docmost_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
apt install git sudo curl wget  unzip   -y 2> /dev/null
BASE_DIR=/mnt/DriveDATA/docmost
mkdir -p $BASE_DIR/db
mkdir -p $BASE_DIR/data
mkdir -p $BASE_DIR/radish
hex_key=$(openssl rand -hex 4)
echo "Generated key is: $hex_key"
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
#read -p "Do you want to set up SMTP? (yes/no): " response
response=no
if [[ "$response" == "yes" || "$response" == "y" ]]; then
read -p "Enter SMTP_HOST: " smtphost
read -p "Enter SMTP_PORT: " smtpport
read -p "Enter User Name: " smtpuname
read -p "Enter FROM-Name: " smtpname
read -p "Enter Passowrd: " smtppwd
else
  echo "Skipping SMTP setup."
fi

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/docmost/docmost-nginx.conf -o docmost-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/docmost/docker-compose.yaml -o docker-compose.yaml
sed -i "s|ChangeMeAppURL|$url|g" docker-compose.yaml
sed -i "s|ChangeMeAppURL|$url|g" docmost-nginx.conf
sed -i "s|ChangeMeSMTPHOST|$smtphost|g" docker-compose.yaml
sed -i "s|ChangeMePORT|$smtpport|g" docker-compose.yaml
sed -i "s|ChangeMeUserNAME|$smtpuname|g" docker-compose.yaml
sed -i "s|ChangeMeMailFrom|$smtpname|g" docker-compose.yaml
sed -i "s|ChangeMePWD|$smtppwd|g" docker-compose.yaml
mv docmost-nginx.conf /etc/nginx/sites-available/docmost
ln -s /etc/nginx/sites-available/docmost /etc/nginx/sites-enabled/docmost
docker compose up -d
sleep 5
echo "To Run Behind nginx proxy please install SSL by certbot --nginx and open URL : $url"