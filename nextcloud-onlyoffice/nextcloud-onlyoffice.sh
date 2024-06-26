#!/bin/bash
apt install git docker-compose -y

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

git clone https://github.com/ONLYOFFICE/docker-onlyoffice-nextcloud
cd docker-onlyoffice-nextcloud
docker-compose up -d
local_ip=$(ip route get 1 | awk '{print $7}')
echo " "
echo " "
echo "Now launch the browser and open  http://$local_ip. The Nextcloud wizard webpage will be opened. Enter all the necessary data to complete the wizard."
echo " "
echo "Run 'bash set_configuration.sh' in terminal in docker-onlyoffice-nextcloud directory, Please note: the action must be performed with root rights."
echo ""
echo "Follow https://github.com/ONLYOFFICE/docker-onlyoffice-nextcloud for more information"
echo ""
sleep 2

