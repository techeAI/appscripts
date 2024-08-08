#!/bin/bash
apt install sudo curl docker-compose -y 2> /dev/null
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/pihole/docker-compose.yml -o docker-compose.yml
sudo mkdir -p /mnt/DriveDATA/pihole
docker-compose up -d
echo ""
echo ""
echo "Setting password for pihole: "
echo ""
docker exec -it pihole bash pihole -a -p
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "Access pihole on  http://$local_ip:81/admin."
sleep 5


