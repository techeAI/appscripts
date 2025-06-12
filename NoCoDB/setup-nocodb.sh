#!/bin/bash
#read -p "Enter the URL(Do not add http or https): https://" app_url
url=$(grep "^nocodedb_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
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
mkdir -p /mnt/DriveDATA/nocodb/{data,database}

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/NoCoDB/docker-compose.yaml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/NoCoDB/nocodb-nginx.conf -o nocodb-nginx.conf
sed -i "s|prefixtables.domainname|$url|g" ./nocodb-nginx.conf
mv nocodb-nginx.conf /etc/nginx/sites-available/nocodb
ln -s /etc/nginx/sites-available/nocodb /etc/nginx/sites-enabled/nocodb
sleep 2
docker-compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:8219 to access NoCoDB."
sleep 5
#echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/mattermost"