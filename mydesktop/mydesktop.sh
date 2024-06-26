#!/bin/bash
BASE_DIR=changebasedir
apt install sudo curl wget xrdp unzip xrdp  -y 2> /dev/null

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

if sudo docker ps --format '{{.Names}}' | grep -q "myDESKTOP"; then
echo "The container 'myDESKTOP' is already running. Skipping installation."
sleep 2
else
echo "Setting up myDESKTOP service..."
curl -L  -o myDESKTOP_config.zip https://github.com/techeAI/appscripts/raw/main/mydesktop/myDESKTOP_config.zip
sudo unzip -q  myDESKTOP_config.zip
sudo mkdir -p $BASE_DIR 2> /dev/null
sudo mv myDESKTOP_config/ $BASE_DIR
sudo rm -rf myDESKTOP_config.zip
local_ip=$(ip route get 1 | awk '{print $7}')
sudo docker run --name=myDESKTOP -p 8201:8080 -v $BASE_DIR/myDESKTOP_config:/config -d --restart unless-stopped oznu/guacamole
sudo sed -i "s/chanegip/$local_ip/g" $BASE_DIR/myDESKTOP_config/guacamole/noauth-config.xml
sudo docker restart myDESKTOP
echo "!!!!!! ############################################### !!!!!!!"
echo " "
echo "Now you can access your device through URL: http://$local_ip:8201"
sleep 5
fi
