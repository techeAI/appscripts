#!/bin/bash

# Complete Setup Script for AWS E2 Instance

# Set strict error handling
set -euo pipefail

# Color codes for better output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Main Execution Function
execute_setup() {
    echo -e "${GREEN}[+] Starting Complete Ollama and Open WebUI Setup${NC}"

    # Step 1: Pre-Setup
    echo -e "${GREEN}[+] Running Pre-Setup Script${NC}"
    chmod +x pre_setup.sh
    sudo ./pre_setup.sh

    # Step 2: Update and Upgrade
    echo -e "${GREEN}[+] Updating System Packages${NC}"
    sudo apt-get update && sudo apt-get upgrade -y

    # Step 3: Main Ollama Setup
    echo -e "${GREEN}[+] Running Ollama Setup Script${NC}"
    chmod +x ollama_setup.sh
    sudo ./ollama_setup.sh

    # Optional: Additional Configurations
    echo -e "${GREEN}[+] Performing Final System Configurations${NC}"
    sudo systemctl enable docker
    sudo usermod -aG docker $USER

    # Cleanup
    echo -e "${GREEN}[+] Cleaning Up Temporary Files${NC}"
    sudo apt-get autoremove -y
    sudo apt-get clean

    # Final Verification
    echo -e "${GREEN}[+] Verifying Ollama and Open WebUI Installation${NC}"
    ollama --version
    docker ps | grep open-webui

    echo -e "${GREEN}[✓] Setup Complete! Open WebUI is ready.${NC}"
}

# Error Handling
handle_error() {
    echo -e "${RED}[!] An error occurred during setup. Please check logs.${NC}"
    exit 1
}

# Trap errors
trap handle_error ERR

# Execute Main Setup
execute_setup
