#!/bin/bash
app_url=$(grep "^uptime_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
local_ip=$(ip route get 1 | awk '{print $7}')
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
mkdir -p /mnt/DriveDATA/uptime-kuma
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/uptime-kuma/docker-compose.yaml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/uptime-kuma/uptime-nginx.conf -o uptime-nginx.conf
sed -i "s|status.domainname|$app_url|g" ./uptime-nginx.conf
mv uptime-nginx.conf /etc/nginx/sites-available/uptime
ln -s /etc/nginx/sites-available/uptime /etc/nginx/sites-enabled/uptime
sleep 2
docker-compose up -d
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:8240 to access uptime."
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/uptime"