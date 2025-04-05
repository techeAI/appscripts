#!/bin/bash

# Pre-Setup Script for AWS E2 Instance

# Logging Setup
PREP_LOG_FILE="/var/log/aws_prep.log"
PREP_ERROR_LOG="/var/log/aws_prep_errors.log"

# Logging Function
prep_log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$PREP_LOG_FILE"
}

# Error Logging Function
prep_error_log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$PREP_LOG_FILE" "$PREP_ERROR_LOG" >&2
}

# Validate Root Access
validate_root() {
    if [ "$EUID" -ne 0 ]; then
        prep_error_log "Please run this script with sudo"
        exit 1
    fi
}

# Main Pre-Setup Function
main_prep() {
    # Validate Root
    validate_root

    # System Update
    prep_log "Updating System Packages..."
    apt-get update && apt-get upgrade -y
    
    # Install Essential Utilities
    prep_log "Installing Essential Utilities..."
    apt-get install -y \
        wget \
        curl \
        git \
        htop \
        net-tools \
        software-properties-common \
        ca-certificates \
        gnupg \
        lsb-release

    # Configure Firewall (if UFW is installed)
    if command -v ufw &> /dev/null; then
        prep_log "Configuring UFW Firewall..."
        ufw allow 22/tcp   # SSH
        ufw allow 80/tcp   # HTTP
        ufw allow 443/tcp  # HTTPS
        ufw allow 11434/tcp # Ollama
        ufw allow 8080/tcp # Open WebUI
    fi

    # Increase Open File Limits
    prep_log "Increasing System File Limits..."
    cat << EOF >> /etc/security/limits.conf
* soft nofile 65535
* hard nofile 65535
root soft nofile 65535
root hard nofile 65535
EOF

    # System Optimization
    prep_log "Applying System Optimizations..."
    sysctl -w vm.swappiness=10
    sysctl -w net.core.somaxconn=65535
    
    # Create Swap File (if no swap exists)
    if [ $(swapon -s | wc -l) -le 1 ]; then
        prep_log "Creating Swap File..."
        fallocate -l 4G /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo "/swapfile none swap sw 0 0" >> /etc/fstab
    fi

    prep_log "Pre-Setup Complete! System is ready for Ollama installation."
}

# Execute Main Preparation
main_prep
