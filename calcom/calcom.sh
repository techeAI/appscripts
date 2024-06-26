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
sudo apt install docker-compose -y


git clone https://github.com/calcom/docker.git
cd docker
cp .env.example .env
echo ""
echo ""
echo "##########################################################################"
echo ""
echo "Now change the values in ./docker/.env file , set SMTP details, base URLs."
echo " "
echo "Also change the volume path, ports in ./docker/docker-compose.yaml (if needed)."
echo ""
echo "After changing the above details, please run below mentioned command."
echo ""
echo "cd ./docker/ && docker-compose pull &&  docker-compose up -d"

echo ""
sleep 5
