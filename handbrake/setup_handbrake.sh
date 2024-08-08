#!/bin/bash

BASE_DIR=/mnt/DriveDATA
apt install sudo curl wget   -y 2> /dev/null

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

if sudo docker ps --format '{{.Names}}' | grep -q "handbrake"; then
echo "The container 'handbrake' is already running. Skipping installation."
sleep 2
else
echo "Setting up handbrake..."
sudo mkdir -p $BASE_DIR/handbrake 2> /dev/null
local_ip=$(ip route get 1 | awk '{print $7}')
docker run -d \
    --name=handbrake \
    -p 8214:5800 \
    -v $BASE_DIR/handbrake/cofig:/config:rw \
    -v $BASE_DIR/handbrake/storage:/storage:ro \
    -v $BASE_DIR/handbrake/watch:/watch:rw \
    -v $BASE_DIR/handbrake/output:/output:rw \
    jlesage/handbrake:v24.01.2
echo "!!!!!! ############################################### !!!!!!!"
echo " "
echo "Now you can access handbrake at URL: http://$local_ip:8214"

echo " ################ INFO ###############"
echo " "
echo "$BASE_DIR/handbrake/cofig: This is where the application stores its configuration, states, log and any files needing persistency. "
echo " "
echo "$BASE_DIR/handbrake/storage: This location contains files from your host that need to be accessible to the application."
echo " "
echo "$BASE_DIR/handbrake/watch: This is where videos to be automatically converted are located."
echo " "
echo "$BASE_DIR/handbrake/output:: This is where automatically converted video files are written."

sleep 5
fi
