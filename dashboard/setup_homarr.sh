#!/bin/bash
wget -qO homarr.sh  https://github.com/techeAI/appscripts/blob/main/dashboard/homarr.sh
update_basedir() {
        echo ""
    echo ""
    echo "Base directory is the path for directory in data disk , like /zfsDrive/zfsPool, if you don't have separate data disk, please put the path form OS disk like /etc/OT "
    echo ""
    read -p "Enter the Base directory path: " new_basedir
    echo $new_basedir > /etc/basedir

    # Replace "changebasedir" in install.sh with the new path
    sed -i "s|changebasedir|$new_basedir|g" ./homarr.sh

    echo "Base directory updated successfully in install.sh."
}

# Check if /etc/basedir file exists
if [ -e "/etc/basedir" ]; then
    # Read the current basedir from the file
    current_basedir=$(cat "/etc/basedir")

    # Ask the user if they want to proceed with the current basedir
    read -p "Base directory found in /etc/basedir: $current_basedir. Do you want to proceed with this? (y/n): " choice


    if [ "$choice" = "y" ]; then
        # User does not want to proceed with the current basedir, update it
     sed -i "s|changebasedir|$current_basedir|g" ./homarr.sh
	else
        # User does not want to proceed with the current basedir, update it
        update_basedir
    fi
else
update_basedir
 fi

bash homarr.sh
