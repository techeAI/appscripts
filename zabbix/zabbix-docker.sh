#!/bin/bash
BASE_DIR=/mnt/DriveDATA
# Install necessary packages
apt update && apt install sudo curl wget lm-sensors -y 2> /dev/null
if [ ! -x /usr/bin/docker ]; then
    echo "Installing Docker..."
    sleep 3
    sudo apt-get -y install docker.io
else
    echo "Docker is already installed."
    sleep 2
fi

# Default values
DEFAULT_FRONTEND_PORT=8080
DEFAULT_SERVER_PORT=10051
DEFAULT_FRONTEND_VOLUME="$BASE_DIR/Zabbix/frontend_data"
DEFAULT_SERVER_VOLUME="$BASE_DIR/Zabbix/server_data"
DEFAULT_DB_VOLUME="$BASE_DIR/Zabbix/mariadb_data"
DEFAULT_DB_ROOT_PASSWORD="root_password"
DEFAULT_DB_NAME="zabbix"
DEFAULT_DB_USER="zabbix"
DEFAULT_DB_PASSWORD="zabbix_password"
NETWORK_NAME="zabbix-network"

# Create directories if they don't exist
mkdir -p $DEFAULT_FRONTEND_VOLUME
mkdir -p $DEFAULT_SERVER_VOLUME
mkdir -p $DEFAULT_DB_VOLUME

# Create a Docker network if it doesn't exist
if ! docker network ls | grep -wq $NETWORK_NAME; then
    docker network create $NETWORK_NAME
fi

echo "Press Enter to use the default value shown in brackets."

# Prompt the user for ports
read -p "Enter the port for Zabbix frontend (default $DEFAULT_FRONTEND_PORT): " FRONTEND_PORT
FRONTEND_PORT=${FRONTEND_PORT:-$DEFAULT_FRONTEND_PORT}

read -p "Enter the port for Zabbix server (default $DEFAULT_SERVER_PORT): " SERVER_PORT
SERVER_PORT=${SERVER_PORT:-$DEFAULT_SERVER_PORT}

# Prompt the user for volumes
read -p "Enter the volume for Zabbix frontend (default $DEFAULT_FRONTEND_VOLUME): " FRONTEND_VOLUME
FRONTEND_VOLUME=${FRONTEND_VOLUME:-$DEFAULT_FRONTEND_VOLUME}

read -p "Enter the volume for Zabbix server (default $DEFAULT_SERVER_VOLUME): " SERVER_VOLUME
SERVER_VOLUME=${SERVER_VOLUME:-$DEFAULT_SERVER_VOLUME}

read -p "Enter the volume for MariaDB (default $DEFAULT_DB_VOLUME): " DB_VOLUME
DB_VOLUME=${DB_VOLUME:-$DEFAULT_DB_VOLUME}

# Prompt the user for database credentials
read -p "Enter the MariaDB root password (default $DEFAULT_DB_ROOT_PASSWORD): " DB_ROOT_PASSWORD
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD:-$DEFAULT_DB_ROOT_PASSWORD}

read -p "Enter the Zabbix database name (default $DEFAULT_DB_NAME): " DB_NAME
DB_NAME=${DB_NAME:-$DEFAULT_DB_NAME}

read -p "Enter the Zabbix database user (default $DEFAULT_DB_USER): " DB_USER
DB_USER=${DB_USER:-$DEFAULT_DB_USER}

read -p "Enter the Zabbix database password (default $DEFAULT_DB_PASSWORD): " DB_PASSWORD
DB_PASSWORD=${DB_PASSWORD:-$DEFAULT_DB_PASSWORD}

# Function to check if a container is running
is_container_running() {
  docker ps --filter "name=$1" --filter "status=running" | grep $1 > /dev/null
}

# Run MariaDB container if not running
if is_container_running "zabbix-mariadb"; then
  echo "MariaDB container is already running."
else
  echo "Starting MariaDB container..."
  docker run -d --name zabbix-mariadb \
    --restart=always \
    --network $NETWORK_NAME \
    -e MYSQL_ROOT_PASSWORD="$DB_ROOT_PASSWORD" \
    -e MYSQL_DATABASE="$DB_NAME" \
    -e MYSQL_USER="$DB_USER" \
    -e MYSQL_PASSWORD="$DB_PASSWORD" \
    -v "$DB_VOLUME":/var/lib/mysql \
    mariadb:11.0.3

  # Wait for MariaDB to initialize
  echo "Waiting for MariaDB to initialize..."
  sleep 30
fi

# Run Zabbix server container if not running
if is_container_running "zabbix-server"; then
  echo "Zabbix server container is already running."
else
  echo "Starting Zabbix server container..."
  docker run -d --name zabbix-server \
    --restart=always \
    --network $NETWORK_NAME \
    -e DB_SERVER_HOST="zabbix-mariadb" \
    -e MYSQL_DATABASE="$DB_NAME" \
    -e MYSQL_USER="$DB_USER" \
    -e MYSQL_PASSWORD="$DB_PASSWORD" \
    -v "$SERVER_VOLUME":/var/lib/zabbix \
    -p $SERVER_PORT:10051 \
    zabbix/zabbix-server-mysql:latest
fi

# Run Zabbix frontend container if not running
if is_container_running "zabbix-frontend"; then
  echo "Zabbix frontend container is already running."
else
  echo "Starting Zabbix frontend container..."
  docker run -d --name zabbix-frontend \
    --restart=always \
    --network $NETWORK_NAME \
    -e ZBX_SERVER_HOST="zabbix-server" \
    -e DB_SERVER_HOST="zabbix-mariadb" \
    -e MYSQL_DATABASE="$DB_NAME" \
    -e MYSQL_USER="$DB_USER" \
    -e MYSQL_PASSWORD="$DB_PASSWORD" \
    -v "$FRONTEND_VOLUME":/var/www/html/zabbix \
    -p $FRONTEND_PORT:8080 \
    zabbix/zabbix-web-nginx-mysql:latest
fi
local_ip=$(ip route get 1 | awk '{print $7}')
sleep 10
echo "Zabbix server is running on port $SERVER_PORT."
echo "Zabbix frontend is running on http://$local_ip:$FRONTEND_PORT."
echo "Please login with default user name 'admin' and password 'zabbix' and change on first login."

