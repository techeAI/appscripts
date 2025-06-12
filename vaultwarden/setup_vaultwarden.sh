#!/bin/bash
#read -p "Will this deployment be publicly accessible? (yes/no): " PUBLIC_DEPLOY
PUBLIC_DEPLOY=$(grep "^vaultwarden_public_deploy=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
url=$(grep "^vaultwarden_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
apt install git sudo curl wget  unzip   -y 2> /dev/null
BASE_DIR=/mnt/DriveDATA
mkdir -p $BASE_DIR/vaultwarden/ssl
local_ip=$(ip route get 1 | awk '{print $7}')
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
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/vaultwarden/vw-nginc.conf -o vw-nginc.conf
sed -i "s|prefixpass.domainname|$url|g" ./vw-nginc.conf
mv vw-nginc.conf /etc/nginx/sites-available/vw
ln -s /etc/nginx/sites-available/vw /etc/nginx/sites-enabled/vw

if [[ "$PUBLIC_DEPLOY" == "yes" ]]; then
echo "Setting up for public deployment..."
docker run -dt --name vaultwarden --restart=unless-stopped -v $BASE_DIR/vaultwarden/:/data/ -p 7077:80 vaultwarden/server:1.32.1
urlscheme="http"
elif [[ "$PUBLIC_DEPLOY" == "no" ]]; then
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout $BASE_DIR/vaultwarden/ssl/vw.key -out $BASE_DIR/vaultwarden/ssl/vw.crt -subj "/C=CT/ST=State/L=City/O=MyOrg/OU=Unit/CN=$local_ip"
docker run -dt --name vaultwarden --restart=unless-stopped -v /mnt/DriveDATA/vaultwarden/:/data/ -e ROCKET_TLS='{certs="/data/ssl/vw.crt",key="/data/ssl/vw.key"}' -p 7077:80 vaultwarden/server:1.32.1
urlscheme="https"
else
    echo "Invalid response. Please enter 'yes' or 'no'."
    exit 1
fi
echo "Now you can access vaultwarden through URL: $urlscheme://$local_ip:7077"
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/vw"