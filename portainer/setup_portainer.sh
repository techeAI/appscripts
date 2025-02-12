#!/bin/bash
BASE_DIR=/mnt/DriveDATA/portainer
apt install wget curl sudo -y 2> /dev/null
if [ ! -x /usr/bin/docker ]; then
echo "Installing docker.."
sleep 3
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



if sudo docker ps --format '{{.Names}}' | grep -q "portainer"; then
				echo "The container Portainer is already running. Skipping installation."
				sleep 2
			else
				echo "Setting up Portainer.."
				sudo mkdir -p $BASE_DIR 2> /dev/null
				sudo docker run --name=portainer -d --restart unless-stopped  -p 8212:9000  -v /var/run/docker.sock:/var/run/docker.sock  -v $BASE_DIR/portainer_data:/data  portainer/portainer-ce:2.21.5
				curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/portainer/portainer-nginx.conf -o portainer-nginx.conf
				mv portainer-nginx.conf /etc/nginx/sites-enabled/portainer
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:8212 to access Portainer and setup."
sleep 5
fi
