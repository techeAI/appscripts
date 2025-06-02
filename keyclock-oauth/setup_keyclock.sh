
#!/bin/bash
apt install git sudo curl wget  unzip   -y 2> /dev/null
#read -p "Enter URL to access keyclock on browser (without http/https)(ex. auth.teche.ai): " url
url=$(grep "^keycloak_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
BASE_DIR=/mnt/DriveDATA/
mkdir -p $BASE_DIR/{postgres,keycloak}
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

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/keyclock-oauth/keyclock-nginx.conf -o keyclock-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/keyclock-oauth/docker-compose.yaml -o docker-compose.yaml
#curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/keyclock-oauth/Dockerfile -o Dockerfile
sed -i "s|changeme-url|$url|g" docker-compose.yaml
sed -i "s|changeme-url|$url|g" keyclock-nginx.conf
mv keyclock-nginx.conf /etc/nginx/sites-available/keyclock
ln -s /etc/nginx/sites-available/keyclock /etc/nginx/sites-enabled/keyclock
docker compose build && docker compose up -d && chown -R 1000:1000 $BASE_DIR/keycloak/keycloak && echo "install SSL certificate an open URL in browser: https://$url"