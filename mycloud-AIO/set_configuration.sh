#!/bin/bash
BASE_DIR=/mnt/DriveDATA/

#Check if nginx is running and download reverse proxy file
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/main/mycloud-AIO/mycloudaio.conf -o mycloudaio.conf
mv mycloudaio.conf /etc/nginx/sites-enabled/mycloudaio

## Setting up
mkdir -p $BASE_DIR/NextcloudAIO/nextcloud_aio_mastercontainer
mkdir -p $BASE_DIR/NextcloudAIO/ncdata
docker volume create nextcloud_aio_mastercontainer
rm -rf /var/lib/docker/volumes/nextcloud_aio_mastercontainer/_data
ln -s $BASE_DIR/NextcloudAIO/nextcloud_aio_mastercontainer/ /var/lib/docker/volumes/nextcloud_aio_mastercontainer/_data

docker run -dt --sig-proxy=false --name nextcloud-aio-mastercontainer --restart unless-stopped --publish 4000:8080 --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config --volume /var/run/docker.sock:/var/run/docker.sock:ro --env SKIP_DOMAIN_VALIDATION=true --env APACHE_PORT=11000 --env APACHE_IP_BINDING=0.0.0.0 --env NEXTCLOUD_DATADIR="$BASE_DIR/NextcloudAIO/ncdata" --env NEXTCLOUD_UPLOAD_LIMIT=1G --env NEXTCLOUD_MAX_TIME=3600 --env NEXTCLOUD_MEMORY_LIMIT=512M --env NEXTCLOUD_STARTUP_APPS="twofactor_totp tasks calendar contacts notes" nextcloud/all-in-one:latest

local_ip=$(ip route get 1 | awk '{print $7}')
echo "************************* For Self hosted please refer***************************************"
echo "AIO URL, Please access https://$local_ip:4000"
echo "myCloud URL. Please access https://$local_ip:11000 "
echo "************************* For Cloud hosted please refer***************************************"
echo "Please edit /etc/nginx/sites-enabled/mycloudaio file to set server_name in reverse proxy"
echo "generate SSL by running certbot --nginx"
echo "If deployed on cloud, Please access URL which is set in reverse proxy for port 4000"