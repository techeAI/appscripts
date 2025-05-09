
#!/bin/bash
apt install git sudo curl wget  unzip   -y 2> /dev/null
BASE_DIR=/mnt/DriveDATA/
mkdir -p $BASE_DIR/{grafana,grafana/alerting,prometheus}
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
read -p "Enter URL to access Grafana on browser (without http/https)(ex. grafana.teche.ai): " url
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/prom-grafana/prom-nginx.conf -o prom-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/prom-grafana/grafana-nginx.conf -o grafana-nginx.conf
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/prom-grafana/prometheus.yml -o prometheus.yml
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/prom-grafana/docker-compose.yaml -o docker-compose.yaml
sed -i "s|changeme-url|$url|g" docker-compose.yaml
sed -i "s|changeme-url|$url|g" grafana-nginx.conf
mv prom-nginx.conf /etc/nginx/sites-available/prom
mv grafana-nginx.conf /etc/nginx/sites-available/grafana
mv prometheus.yml /mnt/DriveDATA/prometheus/prometheus.yml
sudo chown -R 472:472 /mnt/DriveDATA/grafana  # Grafana UID
sudo chown -R 65534:65534 /mnt/DriveDATA/prometheus
ln -s /etc/nginx/sites-available/grafana /etc/nginx/sites-enabled/grafana
docker compose up -d
echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/grafana"