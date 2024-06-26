#!/bin/bash

BASE_DIR=changebasedir
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

if sudo docker ps --format '{{.Names}}' | grep -q "urbackup"; then
    echo "The container 'urBACKUP' is already running. Skipping installation."
    sleep 2
else
    echo "Setting up urBACKUP service.."
    sleep 1
    echo "Please enter backup directory full path, like /Path/To/Dir : "
    read backupdirectory
    if [ -d "$backupdirectory" ]; then
        sudo mkdir -p $BASE_DIR/urbackup/database
        sudo docker run --name=urbackup -d --restart unless-stopped  -p 55413-55415:55413-55415 -p 35623:35623/udp -v $BASE_DIR/urbackup/database/:/var/urbackup -v $backupdirectory:/backups  uroni/urbackup-server
    else
        echo "$backupdirectory does not exist."
    fi
fi

local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:55414 to access urBACKUP."
