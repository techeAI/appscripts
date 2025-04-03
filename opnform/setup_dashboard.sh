#!/bin/bash				
				
				apt install sudo curl wget  -y 2> /dev/null
				BASE_DIR=/mnt/DriveDATA/opnform/
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
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/opnform/opnform-nginx.conf -o opnform-nginx.conf
mv opnform-nginx.conf /etc/nginx/sites-enabled/opnform

docker run -dt --name opnform --restart=unless-stopped -p 35551:80 -eDISABLE_SIGNUP=true -v $BASE_DIR:/persist jhumanj/opnform:1.2.6