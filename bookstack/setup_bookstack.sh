#!/bin/bash
local_ip=$(ip route get 1 | awk '{print $7}')
apt install wget curl docker-compose sudo -y > /dev/null
if [ ! -x /usr/bin/docker ]; then
echo "Installing docker.."
sleep 2
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo setfacl --modify user:$USER:rw /var/run/docker.sock > /dev/null
else
echo "Docker is already installed."
sleep 2
fi
mkdir -p /mnt/DriveDATA/bookstack/
echo "Generating Random App Key"
random_key=$(openssl rand -hex 16)
echo "Generated key: $random_key"
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/bookstack/docker-compose.yaml -o docker-compose.yaml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/bookstack/bs-nginx.conf -o bs-nginx.conf
mv bs-nginx.conf /etc/nginx/sites-enabled/bs
sed -i "s|SomeRandomStringWith32Characters|$random_key|g" ./docker-compose.yaml
sleep 2

read -p "Will this deployment be publicly accessible? (yes/no): " PUBLIC_DEPLOY

if [[ "$PUBLIC_DEPLOY" == "yes" ]]; then
echo "Setting up for public deployment..."
read -p "Enter the URL(Do not add http or https):" app_url
sed -i "s|ChangeMe-APP_URL|$app_url|g" ./docker-compose.yaml
sed -i "s|changemeurlscheme-APP_URL|https|g" ./docker-compose.yaml

elif [[ "$PUBLIC_DEPLOY" == "no" ]]; then
app_url=$local_ip:7076
sed -i "s|ChangeMe-APP_URL|$app_url|g" ./docker-compose.yaml
sed -i "s|changemeurlscheme-APP_URL|http|g" ./docker-compose.yaml
else
    echo "Invalid response. Please enter 'yes' or 'no'."
    exit 1
fi

docker-compose up -d

echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:7076 to access bookstack."
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/bs"