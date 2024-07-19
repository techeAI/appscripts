#!/bin/bash
apt install git sudo curl wget  unzip   -y 2> /dev/null

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


# Prompt the user to enter the interface and timezone
read -p "Enter the interface (put_interface): " interface
read -p "Enter the timezone (put_timezone): " timezone

# Run the Docker command with the user inputs
docker run -d --name ipscanner \
    -e "IFACE=$interface" \
    -e "TZ=$timezone" \
    --network="host" \
    -v /etc/OT/wyl:/data \
    --restart unless-stopped \
    aceberg/watchyourlan
local_ip=$(ip route get 1 | awk '{print $7}')
echo "Now you can access ipscanner through URL: http://$local_ip:8840" 
