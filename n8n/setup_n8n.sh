#!/bin/bash
#read -p "Enter the URL(Do not add http or https):" app_url
app_url=$(grep "^n8n_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
#read -p "Will this deployment be publicly accessible? (yes/no): " PUBLIC_DEPLOY
PUBLIC_DEPLOY=$(grep "^n8n_public_deploy=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
apt install wget curl docker-compose sudo -y 2> /dev/null
if [ ! -x /usr/bin/docker ]; then
echo "Installing docker.."
sleep 2
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
sudo mkdir /mnt/DriveDATA/n8n
sudo chmod 777 /mnt/DriveDATA/n8n
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/n8n/n8n-nginx.conf -o n8n-nginx.conf
sed -i "s|prefixn8n.domainname|$app_url|g" ./n8n-nginx.conf
mv n8n-nginx.conf /etc/nginx/sites-available/n8n
ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/napp_url8n

if [[ "$PUBLIC_DEPLOY" == "yes" ]]; then
echo "Setting up for public deployment..."
docker run -dt  --name n8n  -p 7088:5678 -e GENERIC_TIMEZONE="Asia/Kolkata"  -e TZ="Asia/Kolkata" -e WEBHOOK_URL="https://$app_url" -v /mnt/DriveDATA/n8n:/home/node n8nio/n8n:1.78.0
elif [[ "$PUBLIC_DEPLOY" == "no" ]]; then
docker run -dt  --name n8n  -p 7088:5678 -e GENERIC_TIMEZONE="Asia/Kolkata"  -e TZ="Asia/Kolkata" -e WEBHOOK_URL="http://$app_url" -e N8N_SECURE_COOKIE="false" -v /mnt/DriveDATA/n8n:/home/node n8nio/n8n:1.78.0
else
    echo "Invalid response. Please enter 'yes' or 'no'."
    exit 1
fi

local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
#echo "login http://$local_ip:7088 to access n8n."
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/n8n"