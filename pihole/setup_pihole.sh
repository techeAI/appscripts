#!/bin/bash
apt install sudo curl docker-compose -y 2> /dev/null
wget -O docker-compose.yml  https://openteche.s3.amazonaws.com/TecheOS/pihole/docker-compose.yml
update_basedir() {
        echo ""
    echo ""
    echo "Base directory is the path for directory in data disk , like /zfsDrive/zfsPool, if you don't have separate data disk, please put the path form OS disk like /etc/OT "
    echo ""
    read -p "Enter the Base directory path: " new_basedir
    echo $new_basedir > /etc/basedir

    # Replace "changebasedir" in install.sh with the new path
    sed -i "s|changebasedir|$new_basedir|g" ./docker-compose.yml

    echo "Base directory updated successfully in docker-compose"
}

# Check if /etc/basedir file exists
if [ -e "/etc/basedir" ]; then
    # Read the current basedir from the file
    current_basedir=$(cat "/etc/basedir")

    # Ask the user if they want to proceed with the current basedir
    read -p "Base directory found in /etc/basedir: $current_basedir. Do you want to proceed with this? (y/n): " choice


    if [ "$choice" = "y" ]; then
        # User does not want to proceed with the current basedir, update it
     sed -i "s|changebasedir|$current_basedir|g" ./docker-compose.yml
        else
        # User does not want to proceed with the current basedir, update it
        update_basedir
    fi
else
update_basedir
 fi

docker-compose up -d
echo ""
echo ""
echo "Setting password for pihole: "
echo ""
docker exec -it pihole bash pihole -a -p
local_ip=$(ip route get 1 | awk '{print $7}')
echo "#########################################################"
echo "#########################################################"
echo " "
echo " "
echo "Access pihole on  http://$local_ip:81/admin."
sleep 5


