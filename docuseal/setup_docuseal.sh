#!/bin/bash
$BASE_DIR=/mnt/DriveDATA
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



if sudo docker ps --format '{{.Names}}' | grep -q "docuseal"; then
                                echo "The container 'Docuseal' is already running. Skipping installation."
                                sleep 2
                        else
                                echo "Setting up Docuseal.."
sudo docker run -d --name docuseal --restart unless-stopped  -p 3000:3000 -v $BASE_DIR/docuseal:/data docuseal/docuseal
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:3000 to access docuseal."
sleep 5
fi
