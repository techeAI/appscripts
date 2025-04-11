#!/bin/bash
apt install git sudo curl wget  unzip   -y 2> /dev/null
BASE_DIR=/mnt/DriveDATA/snipeit
mkdir -p $BASE_DIR/db
mkdir -p $BASE_DIR/storage
hex_key=$(openssl rand -base64 32)
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
read -p "Enter Full URL (without http or https):- " url
read -p "Do you want to set up SMTP? (yes/no): " response

if [[ "$response" == "yes" || "$response" == "y" ]]; then
read -p "Enter SMTP_HOST: " smtphost
read -p "Enter SMTP_PORT: " smtpport
read -p "Enter User Name: " smtpuname
read -p "Enter FROM-Name: " smtpname
read -p "Enter Passowrd: " smtppwd
else
  echo "Skipping SMTP setup."
fi

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/snipe-it/snipe-nginx.conf -o snipe-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/snipe-it/docker-compose.yaml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/snipe-it/snipe.env -o snipe.env
#sed -i "s|ChangeMeAppURL|$url|g" docker-compose.yaml
read -p "Will this deployment be publicly accessible? (yes/no): " PUBLIC_DEPLOY
if [[ "$PUBLIC_DEPLOY" == "yes" ]]; then
echo "Setting up for public deployment..."
sed -i "s|ChangeMeAppURL|$url|g" snipe-nginx.conf
sed -i "s|ChangeMeAppURL|$url|g" snipe.env
sed -i "s|ChangeMEAPPKEY|$hex_key|g" snipe.env
sed -i "s|ChangeMeSMTPHOST|$smtphost|g" snipe.env
sed -i "s|ChangeMePORT|$smtpport|g" snipe.env
sed -i "s|ChangeMeUserNAME|$smtpuname|g" snipe.env
sed -i "s|ChangeMeMailFrom|$smtpname|g" snipe.env
sed -i "s|ChangeMePWD|$smtppwd|g" snipe.env
elif [[ "$PUBLIC_DEPLOY" == "no" ]]; then
sed -i "s|ChangeMeAppURL|$url|g" snipe-nginx.conf
sed -i "s|ChangeMeAppURL|$url|g" snipe.env
sed -i "s|ChangeMEAPPKEY|$hex_key|g" snipe.env
sed -i "s|ChangeMeSMTPHOST|$smtphost|g" snipe.env
sed -i "s|ChangeMePORT|$smtpport|g" snipe.env
sed -i "s|ChangeMeUserNAME|$smtpuname|g" snipe.env
sed -i "s|ChangeMeMailFrom|$smtpname|g" snipe.env
sed -i "s|ChangeMePWD|$smtppwd|g" snipe.env
sed -i "s|ChangeMeAppURL|$url|g" snipe.env
sed -i '/^APP_URL=/ s|https://|http://|' ./snipe.env
else
    echo "Invalid response. Please enter 'yes' or 'no'."
    exit 1
fi

mv snipe.env .env
mv snipe-nginx.conf /etc/nginx/sites-enabled/snipe
docker compose up -d
sleep 5
echo "To Run Behind nginx proxy please install SSL by certbot --nginx and open URL https://$url"