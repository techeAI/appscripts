wget -qO docker-compose.yml  https://openteche.s3.amazonaws.com/TecheOS/headscale/docker-compose.yml
wget -qO config.yaml https://openteche.s3.amazonaws.com/TecheOS/headscale/config.yaml
local_ip=$(ip route get 1 | awk '{print $7}')
sed -i "s|change_local_ip|$new_local_ip|g" ./config.yaml
update_basedir() {
    echo ""
    echo ""
    echo "Base directory is the path for directory in data disk , like /zfsDrive/zfsPool, if you don't have separate data disk, please put the path form OS disk like /etc/OT "
    echo ""
    read -p "Enter the Base directory path: " current_basedir
    echo $current_basedir > /etc/basedir
    sed -i "s|changebasedir|$current_basedir|g" ./docker-compose.yml
}

# Check if /etc/basedir file exists
if [ -e "/etc/basedir" ]; then
    # Read the current basedir from the file
    current_basedir=$(cat "/etc/basedir")

    # Ask the user if they want to proceed with the current basedir
    read -p "Base directory found in /etc/basedir: $current_basedir. Do you want to proceed with this? (y/n): " choice
    if [ "$choice" = "y" ]; then
        sed -i "s|changebasedir|$current_basedir|g" ./docker-compose.yml
        else
        # User does not want to proceed with the current basedir, update it
        update_basedir
    fi
else
update_basedir
 fi

apt install sudo curl wget  -y 2> /dev/null
                        if [ ! -x /usr/bin/docker ]; then
echo "Installing docker.."
sleep 3
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
sudo apt install docker-compose -y
docker-compose up -d
mv config.yaml $current_basedir/headscale/config/           
                        echo "######################################################"
                        echo " "
                        echo "Headscale UI can be accessed at the URL http://$local_ip:5000"
                        echo " "
                        sleep 3