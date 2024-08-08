#!/bin/bash				
				
				apt install sudo curl wget  -y 2> /dev/null
				BASE_DIR=/mnt/DriveDATA/DASHBOARD
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


                if sudo docker ps --format '{{.Names}}' | grep -q "teche-dashboard"; then
                                echo "The container 'teche-dashboard' is already running. Skipping installation."
                                sleep 2
                        else
                                echo "Setting up Dashboard..."
								sudo mkdir -p $BASE_DIR/teche-dashboard_configs
								sudo mkdir -p $BASE_DIR/teche-dashboard_icons
                                sudo docker run  --name teche-dashboard  --restart unless-stopped  -p 80:7575  -v $BASE_DIR/teche-dashboard_configs:/app/data/configs  -v /var/run/docker.sock:/var/run/docker.sock -v $BASE_DIR/teche-dashboard_icons:/app/public/icons -v /etc/OT/DASHBOARD/teche-dashboard_data:/data -d docker.io/techeai/techedash:latest
								curl -sL  https://raw.githubusercontent.com/techeAI/appscripts/main/dashboard/default.json -o default.json
								curl -sL  https://raw.githubusercontent.com/techeAI/appscripts/main/dashboard/public.json -o public.json
								mv default.json $BASE_DIR/teche-dashboard_configs/
								mv public.json $BASE_DIR/teche-dashboard_configs/
							
	       	fi
				sudo docker restart teche-dashboard
			file_path="$BASE_DIR/teche-dashboard_configs/default.json"
			local_ip=$(ip route get 1 | awk '{print $7}')
			sudo sed -i "s/serverip/$local_ip/g" "$file_path"

			echo "######################################################"
			echo " "
			echo "Dashboard can be accessed at the URL http://$local_ip"
			echo " "
			sleep 3
			
