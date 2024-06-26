#!/bin/bash
wget -O syncthing.sh  https://openteche.s3.amazonaws.com/TecheOS/syncthing/syncthing.sh
update_basedir() {
        echo ""
    echo ""
    echo " "
    read -p "Enter the directory path which you want to sync, same will be linked to /var/syncthing in Syncthing container: " new_basedir
    echo $new_basedir > /etc/syncdir

    # Replace "changebasedir" in install.sh with the new path
    sed -i "s|syncdir|$new_basedir|g" ./syncthing.sh

    echo "Directory path updated successfully in Syncthing.sh."
}

# Check if /etc/basedir file exists
if [ -e "/etc/syncdir" ]; then
    # Read the current basedir from the file
    current_basedir=$(cat "/etc/syncdir")

    # Ask the user if they want to proceed with the current basedir
    read -p "Sync directory found in /etc/syncdir: $current_basedir. Do you want to proceed with this? (y/n): " choice


    if [ "$choice" = "y" ]; then
        # User does not want to proceed with the current basedir, update it
     sed -i "s|syncdir|$current_basedir|g" ./syncthing.sh
        else
        # User does not want to proceed with the current basedir, update it
        update_basedir
    fi
else
update_basedir
 fi

bash syncthing.sh

