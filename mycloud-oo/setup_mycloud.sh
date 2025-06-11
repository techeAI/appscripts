#!/bin/bash
url=$(grep "^Nextcloud_OO=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
apt install docker-compose sudo curl wget  -y 2> /dev/null

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

curl -L -o docker-compose.yml https://raw.githubusercontent.com/techeAI/appscripts/main/mycloud-oo/docker-compose.yml
curl -L -o nginx.conf https://raw.githubusercontent.com/techeAI/appscripts/main/mycloud-oo/nginx.conf
curl -L -o set_configuration.sh https://raw.githubusercontent.com/techeAI/appscripts/main/mycloud-oo/set_configuration.sh
curl -L -o mycloud-oo-nginx.conf https://raw.githubusercontent.com/techeAI/appscripts/main/mycloud-oo/mycloud-00-nginx.conf

sudo mkdir -p /mnt/DriveDATA/nextcloud-oo/document_data
sudo mkdir -p /mnt/DriveDATA/nextcloud-oo/document_log
sudo mkdir -p /mnt/DriveDATA/nextcloud-oo/app_data
sed -i "s|prefixcloud.domainname|$url|g" ./mycloud-oo-nginx.conf
sudo mv nginx.conf /mnt/DriveDATA/nextcloud-oo/
sudo mv mycloud-oo-nginx.conf /etc/nginx/sites-available/mycloud-oo
ln -s /etc/nginx/sites-available/mycloud-oo /etc/nginx/sites-enabled/mycloud-oo
chown -R www-data:www-data /mnt/DriveDATA/nextcloud-oo/
docker-compose up -d
sleep 20
bash set_configuration.sh
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:8215 to access mycloud."
