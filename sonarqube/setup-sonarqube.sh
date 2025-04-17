#!/bin/bash
#read -p "Enter the URL(Do not add http or https): https://" app_url
echo "Backup /etc/sysctl.conf"
sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak-orig.$(date +%F-%H%M%S)
echo "Backup created: /etc/sysctl.conf.bak-orig.$(date +%F-%H%M%S)"

# Check and append if needed
VM_SETTING="vm.max_map_count=262144"
FS_SETTING="fs.file-max=65536"

# Append only if not already set
grep -q "^$VM_SETTING" /etc/sysctl.conf || echo "$VM_SETTING" | sudo tee -a /etc/sysctl.conf
grep -q "^$FS_SETTING" /etc/sysctl.conf || echo "$FS_SETTING" | sudo tee -a /etc/sysctl.conf

# Apply changes
sudo sysctl -p

BASE_DIR=/mnt/DriveDATA/
mkdir -p $BASE_DIR/sonarqube/{sonarqube_conf,sonarqube_data,sonarqube_extensions,sonarqube_logs,sonarqube_temp,sonar_db,sonar_db_data}

PORT=8223
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
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/sonarqube/sonarqube-nginx.conf -o sonarqube-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/sonarqube/docker-compose.yaml -o docker-compose.yaml
mv sonarqube  /etc/nginx/sites-enabled/sonarqube
apt install wget curl docker-compose sudo -y > /dev/null
docker compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "login http://$local_ip:$PORT to access."
sleep 5
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/sonar"