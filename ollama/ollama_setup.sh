#!/bin/bash

# Logging and Error Handling Setup
LOG_FILE="/var/log/ollama_setup.log"
ERROR_LOG_FILE="/var/log/ollama_setup_errors.log"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Error logging function
error_log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE" "$ERROR_LOG_FILE" >&2
}

# Function to check and exit if last command failed
check_error() {
    if [ $? -ne 0 ]; then
        error_log "$1"
        exit 1
    fi
}

# Validate script is run with sudo
validate_sudo() {
    if [ "$EUID" -ne 0 ]; then
        error_log "Please run this script with sudo"
        exit 1
    fi
}

# Network Configuration Function
configure_network() {
    log "Configuring Network for Ollama and Open WebUI..."
    
    # Configure firewall rules
    if command -v ufw &> /dev/null; then
        ufw allow 11434/tcp  # Ollama default port
        ufw allow 8080/tcp   # Open WebUI default port
    fi

    # Optional: Configure nginx as a reverse proxy
    log "Setting up Nginx Reverse Proxy..."
    apt-get install -y nginx
    
    cat > /etc/nginx/sites-available/ollama_webui <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

    ln -s /etc/nginx/sites-available/ollama_webui /etc/nginx/sites-enabled/
    nginx -t
    systemctl restart nginx
}

# Main setup script
main() {
    # Validate sudo access
    validate_sudo

    log "Starting Ollama and Open WebUI Setup..."

    # Update package lists
    log "Updating package lists..."
    apt-get update
    check_error "Failed to update package lists"

    # Install required dependencies
    log "Installing required dependencies..."
    apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        software-properties-common
    check_error "Failed to install dependencies"

    # Install Ollama
    log "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
    check_error "Failed to install Ollama"

    # Verify Ollama installation
    ollama --version
    check_error "Ollama installation verification failed"

    # Install Docker
    log "Installing Docker..."
    # Remove any existing Docker installations
    apt-get remove -y docker docker-engine docker.io containerd runc

    # Add Docker's official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Set up Docker repository
#    echo \
#    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
#    tee /etc/apt/sources.list.d/docker.list > /dev/null
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
    # Update and install Docker
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    check_error "Failed to install Docker"

    # Pull Llama2 model
    log "Pulling Llama2 model..."
    ollama pull llama2
    check_error "Failed to pull Llama2 model"

    # Configure Network and Proxy
    configure_network

    # Run Open WebUI Docker Container
    log "Starting Open WebUI Docker Container..."
    docker run -d \
        --network=host \
        -v open-webui:/app/backend/data \
        -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
        --name open-webui \
        --restart always \
        ghcr.io/open-webui/open-webui:main
    check_error "Failed to start Open WebUI container"

    # Verify Docker container is running
    docker ps | grep open-webui
    check_error "Open WebUI container failed to start"

    log "Setup Complete! Open WebUI is now available at http://your_server_ip:8080"
}

# Run the main setup function
main
