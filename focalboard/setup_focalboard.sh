#!/bin/bash
BASE_DIR=/mnt/DriveDATA
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
sudo mkdir /mnt/DriveDATA/focalboard && sudo chmod 777 /mnt/DriveDATA/focalboard
if sudo docker ps --format '{{.Names}}' | grep -q "focalboard"; then
                                echo "The container 'focalboard' is already running. Skipping installation."
                                sleep 2
                        else
                                echo "Setting up focalboard.."

sudo docker run -dit --name focalboard --restart unless-stopped -v $BASE_DIR/focalboard:/opt/focalboard/data -p 9999:8000 mattermost/focalboard
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:9999 to access focalboard."
sleep 5
fi
