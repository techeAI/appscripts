#!/bin/bash				
#cho "Dashboard be deployed behind a reverse proxy? (yes/no):"
#read reverse_proxy
dashurl=$(grep "^dashboard_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
vitalurl=$(grep "^vitals_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
reverse_proxy=$(grep "^reverse_proxy=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)			
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
                                sudo docker run -dit --name teche-dashboard-sysvital -p 8208:3001 --restart=unless-stopped -v /:/mnt/host:ro  --privileged --name system_monitor mauricenino/dashdot

                        fi


                if sudo docker ps --format '{{.Names}}' | grep -q "teche-dashboard"; then
                                echo "The container 'teche-dashboard' is already running. Skipping installation."
                                sleep 2
                        else
                                echo "Setting up Dashboard..."

# Check the user's input
if [[ "$reverse_proxy" == "yes" ]]; then
    hport=8080
	curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/dashboard/dashboard-nginx.conf -o dashboard-nginx.conf
sed -i "s|prefixdash.domainname|$dashurl|g" ./dashboard-nginx.conf
sed -i "s|prefixvital.domainname|$vitalurl|g" ./dashboard-nginx.conf
mv dashboard-nginx.conf /etc/nginx/sites-available/dashboard
ln -s /etc/nginx/sites-available/dashboard /etc/nginx/sites-enabled/dashboard
elif [[ "$reverse_proxy" == "no" ]]; then
    hport=80
else
    echo "Invalid input. Please enter 'yes' or 'no'."
fi
								sudo mkdir -p $BASE_DIR/teche-dashboard_configs
								sudo mkdir -p $BASE_DIR/teche-dashboard_icons
								sudo mkdir -p $BASE_DIR/teche-dashboard_data
                                sudo docker run  --name teche-dashboard  --restart unless-stopped  -p $hport:7575  -v $BASE_DIR/teche-dashboard_configs:/app/data/configs  -v /var/run/docker.sock:/var/run/docker.sock -v $BASE_DIR/teche-dashboard_icons:/app/public/icons -v $BASE_DIR/teche-dashboard_data:/data -d docker.io/techeai/techeos:latest
								curl -sL  https://raw.githubusercontent.com/techeAI/appscripts/main/dashboard/default.json -o default.json
#								curl -sL  https://raw.githubusercontent.com/techeAI/appscripts/main/dashboard/public.json -o public.json
								mv default.json $BASE_DIR/teche-dashboard_configs/
#								mv public.json $BASE_DIR/teche-dashboard_configs/

wget -qO $BASE_DIR/teche-dashboard_icons/Biz-App.png https://openteche.s3.amazonaws.com/icons/Biz-App.png
wget -qO $BASE_DIR/teche-dashboard_icons/Dashboard.png https://openteche.s3.amazonaws.com/icons/Dashboard.png
wget -qO $BASE_DIR/teche-dashboard_icons/Diagnostics.png https://openteche.s3.amazonaws.com/icons/Diagnostics.png
wget -qO $BASE_DIR/teche-dashboard_icons/Network.png https://openteche.s3.amazonaws.com/icons/Network.png
wget -qO $BASE_DIR/teche-dashboard_icons/Services.png https://openteche.s3.amazonaws.com/icons/Services.png
wget -qO $BASE_DIR/teche-dashboard_icons/Storage.png https://openteche.s3.amazonaws.com/icons/Storage.png
wget -qO $BASE_DIR/teche-dashboard_icons/System.png https://openteche.s3.amazonaws.com/icons/System.png
wget -qO $BASE_DIR/teche-dashboard_icons/Users.png https://openteche.s3.amazonaws.com/icons/Users.png
fi
				sudo docker restart teche-dashboard
			local_ip=$(ip route get 1 | awk '{print $7}')

			echo "######################################################"
			echo " "
			echo "Dashboard can be accessed at the URL http://$local_ip:$hport"
			echo " "
			echo "To Run Behind nginx proxy please set server_name in /etc/nginx/sites-enabled/dashboard"
			sleep 3