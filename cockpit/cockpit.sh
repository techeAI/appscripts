#!/bin/bash
#Disable CDROM repo in debian
sed -i '/cdrom:/s/^/# /' /etc/apt/sources.list
apt update -y > /dev/null 2>&1 
apt install curl sudo unzip lm-sensors git -y 2> /dev/null
mkdir -p /usr/share/git/
cd /usr/share/git/
git clone https://github.com/techeAI/techeos.git
if [ ! -x /usr/bin/docker ]; then
echo "Installing docker.."
sleep 3
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo setfacl --modify user:$USER:rw /var/run/docker.sock 2> /dev/null
sudo rm -rf get-docker.sh
else
echo "Docker is already installed."
sleep 2
fi

#Disable CDROM repo in debian
sed -i '/cdrom:/s/^/# /' /etc/apt/sources.list

if [ $(dpkg-query -W -f='${Status}' cockpit  2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
			curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/cockpit/wsdd -o wsdd

			wget -sL https://raw.githubusercontent.com/techeAI/appscripts/main/cockpit/wsdd.service -o wsdd.service
			
			echo "Installing Cockpit.."
			apt install sudo unzip -y 2> /dev/null


			sudo apt update -y > /dev/null 2>&1
      			sudo apt  install sudo unzip curl vim  -y
        		sudo mv wsdd.service /etc/systemd/system/wsdd.service
        		sudo mv wsdd /usr/bin/wsdd
else
			
			sudo systemctl daemon-reload >  /dev/null 2>&1 || true
			sudo systemctl restart cockpit.socket >  /dev/null 2>&1 || true
			sudo systemctl enable cockpit.socket >  /dev/null 2>&1 || true
			sudo systemctl restart cockpit >  /dev/null 2>&1 || true
			sudo systemctl enable cockpit >  /dev/null 2>&1 || true
                        local_ip=$(ip route get 1 | awk '{print $7}')
                        echo "Cockpit is already installed and can be accesses at URL https://$local_ip:9090"
                        sleep 5


fi




			sudo chmod 777 /usr/bin/wsdd
			sudo chmod 777 *
			sudo apt-get update -y > /dev/null 2>&1
			sudo apt-get install cockpit -y
			sudo systemctl enable wsdd --now
			#Install Navigator
			wget -q https://github.com/45Drives/cockpit-navigator/releases/download/v0.5.10/cockpit-navigator_0.5.10-1focal_all.deb
			sudo apt install ./cockpit-navigator_0.5.10-1focal_all.deb -y
			rm -rf cockpit-navigator_0.5.10-1focal_all.deb
			echo "Setting up file sharing services"
			curl -sSL https://repo.45drives.com/setup | sudo bash
			sudo apt-get update -y > /dev/null 2>&1
			sudo apt install cockpit-file-sharing -y
			#Setting up identities
			curl -sSL https://repo.45drives.com/setup | sudo bash 2> /dev/null
			sudo apt update -y > /dev/null 2>&1
			sudo apt install cockpit-identities -y
			
			#Install sensors

			echo "Configuring sensors..."
			wget -q https://github.com/ocristopfer/cockpit-sensors/releases/latest/download/cockpit-sensors.tar.xz && \
  			tar -xf cockpit-sensors.tar.xz cockpit-sensors/dist && \
  			mv cockpit-sensors/dist /usr/share/cockpit/sensors 2> /dev/null && \
  			rm -rf cockpit-sensors 2> /dev/null && \
  			rm -rf cockpit-sensors.tar.xz 2> /dev/null
		
			#Installing temperature plugin
			echo "Configuring temperature plugin"
			cd /usr/share/cockpit/
			git clone https://github.com/pascal-fb-martin/cockpit-temperature-plugin.git
			cd -
			systemctl restart cockpit.socket		

########ZFS
install_zfs() {
        if grep -q "Zorin\|Ubuntu" /etc/os-release; then
                sudo apt-get install zfsutils-linux -y

          			  echo "Setting up storage services..."
          			  git clone https://github.com/optimans/cockpit-zfs-manager.git
          			  /usr/bin/sudo /usr/bin/cp -r ./cockpit-zfs-manager/zfs /usr/share/cockpit/zfs
          			  rm -rf cockpit-zfs-manager
                                  echo "ZFS installed, please consider rebooting your system after installation."
        			  echo " "
        			  echo " "
        			  sleep 5
                elif grep -q "Debian" /etc/os-release; then
                sudo sed -r -i'.BAK' 's/^deb(.*)$/deb\1 contrib/g' /etc/apt/sources.list
                sudo apt update -y > /dev/null 2>&1
                sudo apt install linux-headers-amd64 zfsutils-linux zfs-dkms zfs-zed -y

          			  echo "Setting up storage services..."
          			  git clone https://github.com/optimans/cockpit-zfs-manager.git
          			  /usr/bin/sudo /usr/bin/cp -r cockpit-zfs-manager/zfs /usr/share/cockpit/zfs
          			  rm -rf cockpit-zfs-manager
                                  echo "ZFS installed, please consider rebooting your system after installation."
        			  echo " "
        			  echo " "
        			  sleep 5
        else
                echo "Unsupported distribution. Installing ZFS with default options."
                sudo apt-get install zfsutils-linux -y

          			  echo "Setting up storage services..."
          			  git clone https://github.com/optimans/cockpit-zfs-manager.git
          			  /usr/bin/sudo /usr/bin/cp -r cockpit-zfs-manager/zfs /usr/share/cockpit/zfs
          			  rm -rf cockpit-zfs-manager
                                  echo "ZFS installed, please consider rebooting your system after installation."
        			  echo " "
        			  echo " "
        			  sleep 5
        fi
        }

        # Prompt user to install ZFS
        read -p "Do you want to install ZFS? (y/n): " install_zfs_answer

        # Convert answer to lowercase
        install_zfs_answer="${install_zfs_answer,,}"

        # Check user's response
        if [[ $install_zfs_answer == "y" || $install_zfs_answer == "yes" ]]; then


		# Check if ZFS is installed
			if ! command -v zfs &> /dev/null; then
    				echo "ZFS is not installed. Proceeding with installation..."

			          install_zfs
        		else
                		  echo "Skipping ZFS installation, it is already installed."
        		fi

        else
           echo "Skipping ZFS installation"
        fi

			#Install Machines
			sudo apt-get install cockpit-machines -y

			sudo systemctl daemon-reload >  /dev/null 2>&1 || true
			sudo systemctl restart cockpit.socket >  /dev/null 2>&1 || true
			sudo systemctl enable cockpit.socket >  /dev/null 2>&1 || true
			sudo systemctl restart cockpit >  /dev/null 2>&1 || true
			sudo systemctl enable cockpit >  /dev/null 2>&1 || true
			systemctl stop cockpit
			mv /usr/share/cockpit /usr/share/_cockpit
			ln -snf /usr/share/git/techeos/cockpit /usr/share/cockpit
			systemctl start cockpit
			#Allow root user to access cockpit web console
			sed -i '/^root/ s/^/#/' /etc/cockpit/disallowed-users && systemctl restart cockpit

			local_ip=$(ip route get 1 | awk '{print $7}')
			echo "!!!!!! ############################################### !!!!!!!"
			echo " "
			echo "Cockpit can be accessed at URL https://$local_ip:9090. Please reboot the system before accessing."
			sleep 5
		        rm -rf cockpit.sh
				sleep 2
########
