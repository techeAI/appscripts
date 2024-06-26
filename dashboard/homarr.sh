#!/bin/bash				
				
				apt install sudo curl wget  -y 2> /dev/null
				BASE_DIR=changebasedir/homarr
				curl -sL https://raw.githubusercontent.com/techeAI/appscripts/blob/main/dashboard/default.json -o default.json
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

				if sudo docker ps --format '{{.Names}}' | grep -q "system_monitor"; then
                                echo "The container 'system_monitor' is already running. Skipping installation."
                                sleep 2
                        else
                               echo "Setting up System Monitoring service..."
                                sudo docker run -dit -p 8208:3001 --restart=unless-stopped -v /:/mnt/host:ro  --privileged --name system_monitor mauricenino/dashdot

                        fi


                if sudo docker ps --format '{{.Names}}' | grep -q "homarr"; then
                                echo "The container 'Homarr' is already running. Skipping installation."
                                sleep 2
                        else
                                echo "Setting up Dashboard..."
								sudo mkdir -p /$BASE_DIR/homarr_configs
								sudo mkdir -p /$BASE_DIR/homarr_icons
                                sudo docker run  --name homarr  --restart unless-stopped -e "DEFAULT_COLOR_SCHEME=dark" -p 80:7575  -v /$BASE_DIR/homarr_configs:/app/data/configs  -v /var/run/docker.sock:/var/run/docker.sock -v /$BASE_DIR/homarr_icons:/app/public/icons  -d docker.io/techeai/techedash:latest
				sudo  mv default.json /$BASE_DIR/homarr_configs/default.json
				sudo chmod 666 /$BASE_DIR/homarr_configs/default.json
				sudo docker restart homarr				
                        fi
			file_path="/$BASE_DIR/homarr_configs/default.json"
			local_ip=$(ip route get 1 | awk '{print $7}')
			sudo sed -i "s/changeip/$local_ip/g" "$file_path"

			echo "######################################################"
			echo " "
			echo "Dashboard can be accessed at the URL http://$local_ip"
			echo " "
			sleep 3
