#!/bin/bash
apt install git sudo curl wget  unzip   -y 2> /dev/null

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


# Default values
DEFAULT_PORT="5020"
DEFAULT_VOLUME1="/etc/OT/Stiring_trainingData:/usr/share/tessdata"
DEFAULT_VOLUME2="/etc/OT/Stiring_extraConfigs:/configs"
DEFAULT_VOLUME3="/etc/OT/Stiring_logs:/logs"

# Function to prompt user for input with a default value
prompt() {
  local prompt_text=$1
  local default_value=$2
  read -p "$prompt_text [$default_value]: " input
  echo "${input:-$default_value}"
}

# Function to create directory if it doesn't exist
create_directory() {
  local volume_mapping=$1
  local host_dir=${volume_mapping%%:*}  # Extract the host directory part of the volume mapping

  if [ ! -d "$host_dir" ]; then
    echo "Creating directory $host_dir"
    mkdir -p "$host_dir"
  else
    echo "Directory $host_dir already exists"
  fi
}

# Prompt the user for input
PORT=$(prompt "Enter the external port" "$DEFAULT_PORT")
VOLUME1=$(prompt "Enter the first volume mapping" "$DEFAULT_VOLUME1")
VOLUME2=$(prompt "Enter the second volume mapping" "$DEFAULT_VOLUME2")
VOLUME3=$(prompt "Enter the third volume mapping" "$DEFAULT_VOLUME3")

# Create the directories if they don't exist
create_directory "$VOLUME1"
create_directory "$VOLUME2"
create_directory "$VOLUME3"

# Run the Docker container with the provided or default values
docker run -d \
  -p $PORT:8080 \
  --restart unless-stopped \
  -v $VOLUME1 \
  -v $VOLUME2 \
  -v $VOLUME3 \
  -e DOCKER_ENABLE_SECURITY=false \
  -e INSTALL_BOOK_AND_ADVANCED_HTML_OPS=false \
  -e LANGS=en_GB \
  --name stirling-pdf \
  frooodle/s-pdf:latest
  
local_ip=$(ip route get 1 | awk '{print $7}')
echo "Now you can access ipscanner through URL: http://$local_ip:$PORT"
