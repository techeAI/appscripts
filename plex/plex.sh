#!/bin/bash
MEDIA=mediadir
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



if sudo docker ps --format '{{.Names}}' | grep -q "plex"; then
                                echo "The container 'Plex' is already running. Skipping installation."
                                sleep 2
                        else
                                echo "Setting up Plex.."
sudo mkdir -p $MEDIA 2> /dev/null
sudo docker run -d --name=plex --net=host -e PUID=1000 -e PGID=1000 -e TZ=Etc/UTC -e VERSION=docker --device=/dev/dri:/dev/dri  -v $MEDIA:/movies --restart unless-stopped  lscr.io/linuxserver/plex:latest				
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:32400/web to access Plex."
sleep 5
fi
