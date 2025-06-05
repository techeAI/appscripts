#!/bin/bash
apt install wget curl sudo -y 2> /dev/null
url=$(grep "^suite_CRM=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
BASE_DIR=/mnt/DriveDATA
if [ ! -x /usr/bin/docker ]; then
echo "Installing docker.."
sleep 2
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
apt install docker-compose -y
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/suitecrm/crm-nginx.conf -o crm-nginx.conf
sed -i "s|prefixcrm.domainname|$url|g" ./headscale-nginx.conf
mv crm-nginx.conf /etc/nginx/sites-available/crm
ln -s /etc/nginx/sites-available/crm /etc/nginx/sites-enabled/crm
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/suitecrm/docker-compose.yaml -o docker-compose.yaml
# Function to get user input with a default value
get_user_input() {
    local prompt="$1"
    local default="$2"
    local input

    read -p "$prompt [$default]: " input
    echo "${input:-$default}"
}

# Get user inputs
MARIADB_ROOT_PASSWORD=$(get_user_input "Enter MariaDB root password" "aPUo56ZCWR")
MARIADB_USER=$(get_user_input "Enter MariaDB user" "bn_suitecrm")
MARIADB_PASSWORD=$(get_user_input "Enter MariaDB password" "aPUo56ZCWR")
MARIADB_DATABASE=$(get_user_input "Enter MariaDB database" "bitnami_suitecrm")
MARIADB_VOLUME=$(get_user_input "Enter absolute path for MariaDB volume" "$BASE_DIR/suitecrm/suitecrm_db")
#SUITECRM_PORT_HTTP=$(get_user_input "Enter SuiteCRM HTTP port" "5010")
SUITECRM_PORT_HTTP=5010
#SUITECRM_PORT_HTTPS=$(get_user_input "Enter SuiteCRM HTTPS port" "5011")
SUITECRM_PORT_HTTPS=5011
SUITECRM_DATABASE_USER=$(get_user_input "Enter SuiteCRM database user" "bn_suitecrm")
SUITECRM_DATABASE_PASSWORD=$(get_user_input "Enter SuiteCRM database password" "aPUo56ZCWR")
SUITECRM_DATABASE_NAME=$(get_user_input "Enter SuiteCRM database name" "bitnami_suitecrm")
SUITECRM_VOLUME=$(get_user_input "Enter absolute path for SuiteCRM volume" "$BASE_DIR/suitecrm/suitecrm_data")

# Create directories if they do not exist with appropriate permissions
mkdir -p "$MARIADB_VOLUME"
mkdir -p "$SUITECRM_VOLUME"
chmod -R 777 "$MARIADB_VOLUME"
chmod -R 777 "$SUITECRM_VOLUME"

# Replace placeholders in the docker-compose.yaml file
sed -i "s|\${MARIADB_ROOT_PASSWORD}|$MARIADB_ROOT_PASSWORD|g" docker-compose.yaml
sed -i "s|\${MARIADB_USER}|$MARIADB_USER|g" docker-compose.yaml
sed -i "s|\${MARIADB_PASSWORD}|$MARIADB_PASSWORD|g" docker-compose.yaml
sed -i "s|\${MARIADB_DATABASE}|$MARIADB_DATABASE|g" docker-compose.yaml
sed -i "s|\${MARIADB_VOLUME}|$MARIADB_VOLUME|g" docker-compose.yaml
sed -i "s|\${SUITECRM_PORT_HTTP}|$SUITECRM_PORT_HTTP|g" docker-compose.yaml
sed -i "s|\${SUITECRM_PORT_HTTPS}|$SUITECRM_PORT_HTTPS|g" docker-compose.yaml
sed -i "s|\${SUITECRM_DATABASE_USER}|$SUITECRM_DATABASE_USER|g" docker-compose.yaml
sed -i "s|\${SUITECRM_DATABASE_PASSWORD}|$SUITECRM_DATABASE_PASSWORD|g" docker-compose.yaml
sed -i "s|\${SUITECRM_DATABASE_NAME}|$SUITECRM_DATABASE_NAME|g" docker-compose.yaml
sed -i "s|\${SUITECRM_VOLUME}|$SUITECRM_VOLUME|g" docker-compose.yaml

docker-compose -f ./docker-compose.yaml up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo  "Please access the suiteCRM at http://$local_ip:$SUITECRM_PORT_HTTP or https://$local_ip:$SUITECRM_PORT_HTTPS"
echo ""
echo ""
echo "Default login details are:"
echo "Username : user"
echo "Password: bitnami"
echo "Please change default username and password upon first login"
sleep 10
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/crm"
#echo "docker-compose.yaml has been updated with the provided values."
#echo "Directories have been created with appropriate permissions if they did not already exist."
