#!/bin/bash
SYNCDIR=syncdir
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



if sudo docker ps --format '{{.Names}}' | grep -q "syncthing"; then
                                echo "The container 'syncthing' is already running. Skipping installation."
                                sleep 2
                        else
                                echo "Setting up Syncthing.."
sudo docker run -d --network=host --name=syncthing  -v $SYNCDIR:/var/syncthing  --hostname=my-syncthing  syncthing/syncthing:latest
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:8384 to access Syncthing."
sleep 5
fi
