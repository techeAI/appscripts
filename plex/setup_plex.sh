#!/bin/bash
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/plex/plex.sh -o plex.sh
update_basedir() {

    echo ""
    echo ""
    echo "Media directory is the path for your media directory, like /mnt/media , where you stored your movies "
    echo ""

    read -p "Enter the Media directory path, same will be linked to /movies in Plex container: " new_basedir
    echo $new_basedir > /etc/mediadir

    # Replace "changebasedir" in install.sh with the new path
    sed -i "s|mediadir|$new_basedir|g" ./plex.sh

    echo "Media directory updated successfully in plex.sh."
}

# Check if /etc/basedir file exists
if [ -e "/etc/mediadir" ]; then
    # Read the current basedir from the file
    current_basedir=$(cat "/etc/mediadir")

    # Ask the user if they want to proceed with the current basedir
    read -p "Base directory found in /etc/mediadir: $current_basedir. Do you want to proceed with this? (y/n): " choice


    if [ "$choice" = "y" ]; then
        # User does not want to proceed with the current basedir, update it
     sed -i "s|mediadir|$current_basedir|g" ./plex.sh
        else
        # User does not want to proceed with the current basedir, update it
        update_basedir
    fi
else
update_basedir
 fi

bash plex.sh

