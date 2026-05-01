sudo apt update -y
apt install sudo nginx nginx-common htop curl snapd
apt-get remove certbot
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

## Create config directory
mkdir -p /mnt/DriveDATA/Deploy-config/

## Create URL file and add url for headscale
vim /mnt/DriveDATA/Deploy-config/urls.conf
headscale_url=vpn.teche.host

## Install Headscale
mkdir /mnt/DriveDATA/Deploy-config/headscale && cd /mnt/DriveDATA/Deploy-config/headscale
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/headscale/setup_headscale.sh -o setup_headscale.sh && bash setup_headscale.sh

## Create DNS A record
certtbot --nginx

## After Sucessfull install open GUI in browser as https://url/web
## Default Username: admin
## Default Password: admin

## Login to server and run below command to generate API key first and note it down.
docker exec headscale-main headscale apikeys create


## Now Open GUI in browser as /web (https://vpn.teche.host/web)
## Login with username and password and click on settings.
## Fill Headscale URL and Headscale API Key and click on Test Server Settings