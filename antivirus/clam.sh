#!/bin/bash
# Check if clamav and clamav-daemon are installed
apt install curl wget sudo -y 2> /dev/null
if dpkg -l | grep -E '^ii' | grep -q 'clamav' && dpkg -l | grep -E '^ii' | grep -q 'clamav-daemon'; then
    echo "ClamAV already installed."
else
    #Install clamav and clamav-daemon
   sudo apt-get update -y
   sudo apt-get install clamav clamav-daemon -y
   sudo systemctl stop clamav-freshclam
   sudo freshclam
   sudo systemctl start clamav-freshclam
   sudo systemctl enable clamav-freshclam
   echo "ClamAV installed"
   sudo systemctl enable clamav-daemon --now
fi

if dpkg -l | grep -E '^ii' | grep -q 'clamtk'; then
    echo "ClamTk already installed."
else
    # Prompt the user to install ClamTk
    read -p "ClamTk (A GUI for ClamAV) is not installed. Do you want to install it? (Y/N): " answer

    # Convert the answer to uppercase
    answer=$(echo "$answer" | tr '[:lower:]' '[:upper:]')

    # Check the user's response
    if [ "$answer" == "Y" ]; then
        # Install clamtk
        sudo apt-get update
        sudo apt-get install clamtk -y
	sudo systemctl restart clamav-daemon
    else
        echo "ClamTk installation skipped."
    fi
fi
