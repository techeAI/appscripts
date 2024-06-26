#!/bin/bash
apt install sudo curl wget  unzip   -y 2> /dev/null

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

wget -qO JITSI.zip  $(curl -s https://api.github.com/repos/jitsi/docker-jitsi-meet/releases/latest | grep 'zip' | cut -d\" -f4)
mkdir -p ./JITSI
unzip JITSI.zip -d ./JITSI
cd ./JITSI/*
cp env.example .env
bash gen-passwords.sh
read -p "Put the http port, you want to access Jisti On: " httpport
sed -i "s/8000/$httpport/g" .env
read -p "Put the https port, you want to access Jisti On: " httpsport
sed -i "s/8443/$httpsport/g" .env
read -p "Enter the base directory path: " BASE_DIR
sudo mkdir -p $BASE_DIR/.jitsi-meet-cfg/{web,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}
sed -i 's/8080/8090/g' docker-compose.yml 
docker-compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "Jitsi running  on http://$local_ip:$httpport  and https://$local_ip:$httpsport " 
