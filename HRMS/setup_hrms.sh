#!/bin/bash
#read -p "Will this deployment be publicly accessible? (yes/no): " PUBLIC_DEPLOY
PUBLIC_DEPLOY=$(grep "^hrms_public_deploy=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
local_ip=$(ip route get 1 | awk '{print $7}')
apt install wget curl sudo -y 2> /dev/null
BASE_DIR=/mnt/DriveDATA/hrms
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
apt install docker-compose -y
mkdir -p $BASE_DIR
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/HRMS/hrms-nginx.conf -o hrms-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/HRMS/docker-compose.yaml -o docker-compose.yaml

if [[ "$PUBLIC_DEPLOY" == "yes" ]]; then
echo "Setting up for public deployment..."
#read -p "Enter the URL(Do not add http or https):" app_url
app_url=$(grep "^hrms_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f)
sed -i "s|ChangeMe-APP_URL|$app_url|g" ./docker-compose.yaml
sed -i "s|ChangeMe-APP_URL|$app_url|g" ./hrms-nginx.conf
mv hrms-nginx.conf /etc/nginx/sites-available/hrms
ln -s /etc/nginx/sites-available/hrms /etc/nginx/sites-enabled/hrms
elif [[ "$PUBLIC_DEPLOY" == "no" ]]; then
sed -i "s|ip|$local_ip|g" ./docker-compose.yaml
else
    echo "Invalid response. Please enter 'yes' or 'no'."
    exit 1
fi
docker compose up -d
echo  "Please access the HRMS at http://$local_ip:7072"
echo ""
echo ""
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/hrms"