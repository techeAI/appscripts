#!/bin/bash
BASE_DIR=changebasedir
apt install sudo wget curl -y 2> /dev/null
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

if sudo docker ps --format '{{.Names}}' | grep -q "Shinobi"; then
echo "The container 'Shinobi' is already running. Skipping installation."
sleep 2
else
sudo docker run -dt --restart unless-stopped --name='Shinobi' --net=host -v "/dev/shm/Shinobi/streams":'/dev/shm/streams':'rw' -v "$BASE_DIR/Shinobi/config":'/config':'rw' -v "$BASE_DIR/Shinobi/customAutoLoad":'/home/Shinobi/libs/customAutoLoad':'rw' -v "$BASE_DIR/Shinobi/database":'/var/lib/mysql':'rw' -v "$BASE_DIR/Shinobi/videos":'/home/Shinobi/videos':'rw' -v "$BASE_DIR/Shinobi/plugins":'/home/Shinobi/plugins':'rw' -v '/etc/localtime':'/etc/localtime':'ro' registry.gitlab.com/shinobi-systems/shinobi:dev
echo "Deploying container...Please don't exit."
sleep 10
sudo /usr/bin/sed -i 's/localhost/127.0.0.1/g' $BASE_DIR/Shinobi/config/conf.json
sudo docker restart Shinobi

local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "Default Username: admin@shinobi.video and password: admin "
sleep 3
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:8080/super from any device to create new admin user."
sleep 5
fi
