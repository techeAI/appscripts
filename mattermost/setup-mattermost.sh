#!/bin/bash
local_ip=$(ip route get 1 | awk '{print $7}')
app_url=$(grep "^mattermost_URL=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
PUBLIC_DEPLOY=$(grep "^mattermost_public_deploy=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
apt install wget curl docker-compose sudo -y > /dev/null
if [ ! -x /usr/bin/docker ]; then
echo "Installing docker.."
sleep 2
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo setfacl --modify user:$USER:rw /var/run/docker.sock > /dev/null
else
echo "Docker is already installed."
sleep 2
fi
mkdir -p /mnt/DriveDATA/mattermost/{config,config/ssl,data,logs,plugins,client/plugins,bleve-indexes}
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /mnt/DriveDATA/mattermost/config/ssl/mattermost.key -out /mnt/DriveDATA/mattermost/config/ssl/mattermost.crt -subj "/C=CT/ST=State/L=City/O=MyOrg/OU=Unit/CN=$local_ip"
sudo chown -R 2000:2000 /mnt/DriveDATA/mattermost/
#sudo chmod -R 777 /mnt/DriveDATA/mattermost/
#echo "Generating Random App Key"
#random_key=$(openssl rand -hex 16)
#echo "Generated key: $random_key"
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mattermost/docker-compose.yaml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mattermost/mattermost-nginx.conf -o mattermost-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mattermost/mattermost.env -o mattermost.env

#read -p "Will this deployment be publicly accessible? (yes/no): " PUBLIC_DEPLOY

if [[ "$PUBLIC_DEPLOY" == "yes" ]]; then
echo "Setting up for public deployment..."
#read -p "Enter the URL(Do not add http or https):" app_url
sed -i "s|ChangeMe-APP_URL|$app_url|g" ./mattermost.env
sed -i "s|ChangeMe-APP_URL|$app_url|g" ./mattermost-nginx.conf
elif [[ "$PUBLIC_DEPLOY" == "no" ]]; then
sed -i "s|ChangeMe-APP_URL|$local_ip:8217|g" ./mattermost.env
#sed -i "s|ChangeMe-APP_URL|$local_ip|g" ./mattermost-nginx.conf
sed -i '/^#.*MM_SERVICESETTINGS_TLSCERTFILE/s/^#//' ./mattermost.env
sed -i '/^#.*MM_SERVICESETTINGS_TLSKEYFILE/s/^#//' ./mattermost.env
#sed -i '/^MM_SERVICESETTINGS_SITEURL=/ s|https://|http://|' ./mattermost.env
else
    echo "Invalid response. Please enter 'yes' or 'no'."
    exit 1
fi
mv mattermost-nginx.conf /etc/nginx/sites-available/mattermost
ln -s /etc/nginx/sites-available/mattermost /etc/nginx/sites-enabled/mattermost
mv mattermost.env .env

sleep 2
docker-compose up -d

echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login https://$local_ip:8217 to access mattermost."
sleep 5
#echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/mattermost"