#!/bin/bash
url=$(grep "^focalboard_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
BASE_DIR=/mnt/DriveDATA
PORT=7089
apt install wget curl sudo -y 2> /dev/null
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
sudo mkdir $BASE_DIR/focalboard && sudo chmod 777 $BASE_DIR/focalboard
if sudo docker ps --format '{{.Names}}' | grep -q "focalboard"; then
                                echo "The container 'focalboard' is already running. Skipping installation."
                                sleep 2
                        else
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/focalboard/focal-nginx.conf -o focal-nginx.conf
sed -i "s|prefixboard.domainname|$url|g" focal-nginx.conf
mv focal-nginx.conf /etc/nginx/sites-available/focal
ln -s /etc/nginx/sites-available/focal /etc/nginx/sites-enabled/focal
                                echo "Setting up focalboard.."

sudo docker run -dt --name focalboard --restart unless-stopped -v $BASE_DIR/focalboard:/opt/focalboard/data -p $PORT:8000 mattermost/focalboard:7.8.9
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:$PORT to access focalboard."
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/focal"
fi