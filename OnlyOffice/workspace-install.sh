#!/bin/bash
apt install sudo curl wget -y 2> /dev/null
wget -O install.sh  https://openteche.s3.amazonaws.com/TecheOS/OnlyOffice/install.sh

if [ ! -x /usr/bin/docker ];  then
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

# (c) Copyright Ascensio System Limited 2010-2021
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
# You can contact Ascensio System SIA by email at sales@onlyoffice.com

# Function to read user input and update basedir in install.sh
update_basedir() {
    echo ""
    echo ""
    echo "Base directory is the path for directory in data disk , like /zfsDrive/zfsPool, if you don't have separate data disk, please put the path form OS disk like /etc/OT "
    echo ""
    read -p "Enter the Base directory path "" : " new_basedir
    echo $new_basedir > /etc/basedir

    # Replace "changebasedir" in install.sh with the new path
    sed -i "s|changebasedir|$new_basedir|g" ./install.sh

    echo "Base directory updated successfully in install.sh."
}

# Check if /etc/basedir file exists
if [ -e "/etc/basedir" ]; then
    # Read the current basedir from the file
    current_basedir=$(cat "/etc/basedir")

    # Ask the user if they want to proceed with the current basedir
    read -p "Base directory found in /etc/basedir: $current_basedir. Do you want to proceed with this? (y/n): " choice


    if [ "$choice" = "y" ]; then
        # User does not want to proceed with the current basedir, update it
     sed -i "s|changebasedir|$current_basedir|g" ./install.sh
        else
        # User does not want to proceed with the current basedir, update it
        update_basedir
    fi
else
update_basedir
 fi

set -e

PARAMETERS="";
DOCKER="";
HELP="false";

while [ "$1" != "" ]; do
        case $1 in

	-ls | --localscripts )
	        if [ "$2" == "true" ] || [ "$2" == false ]; then
			PARAMETERS="$PARAMETERS ${1}";
			LOCAL_SCRIPTS=$2
			shift
		fi
         ;;

	 "-?" | -h | --help )
	        HELP="true"
		DOCKER="true"
		PARAMETERS="$PARAMETERS -ht workspace-install.sh";
	 ;;

	esac
	PARAMETERS="$PARAMETERS ${1}";
	shift
done

PARAMETERS="$PARAMETERS -it WORKSPACE";

root_checking () {
	if [ ! $( id -u ) -eq 0 ]; then
		echo "To perform this action you must be logged in with root rights"
		exit 1;
	fi
}

command_exists () {
	type "$1" &> /dev/null;
}

install_curl () {
	if command_exists apt-get; then
		apt-get -y update
		apt-get -y -q install curl
	elif command_exists yum; then
		yum -y install curl
	fi

	if ! command_exists curl; then
		echo "command curl not found"
		exit 1;
	fi
}

read_installation_method () {
	echo "Select 'Y' to install ONLYOFFICE using Docker (recommended). Select 'N' to install it using RPM/DEB packages.";
#	echo "Please note, that in case you select RPM/DEB installation, you will need to manually install Mail Server and connect it to your ONLYOFFICE installation.";
	echo "See instructions in our Help Center: http://helpcenter.onlyoffice.com/server/docker/mail/connect-mail-server-to-community-server-via-portal-settings.aspx";
	read -p "Install with Docker [Y/N/C]? " choice
	case "$choice" in
		y|Y )
			DOCKER="true";
		;;

		n|N )
			DOCKER="false";
		;;

		c|C )
			exit 0;
		;;

		* )
			echo "Please, enter Y, N or C to cancel";
		;;
	esac

	if [ "$DOCKER" == "" ]; then
		read_installation_method;
	fi
}

root_checking

if ! command_exists curl ; then
	install_curl;
fi

if [ "$HELP" == "false" ]; then
	read_installation_method;
fi

if [ "$DOCKER" == "true" ]; then
	if [ "${LOCAL_SCRIPTS}" == "true" ]; then
		sudo bash ./install.sh ${PARAMETERS}
	else
#		curl -s -O http://download.onlyoffice.com/install/install.sh
		 sudo bash ./install.sh ${PARAMETERS}
#		rm install.sh
	fi
else
	if [ -f /etc/redhat-release ] ; then
		DIST=$(cat /etc/redhat-release |sed s/\ release.*//);
		REV=$(cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//);

		REV_PARTS=(${REV//\./ });
		REV=${REV_PARTS[0]};

		if [[ "${DIST}" == CentOS* ]] && [ ${REV} -lt 7 ]; then
			echo "CentOS 7 or later is required";
			exit 1;
		fi

		if [ "${LOCAL_SCRIPTS}" == "true" ]; then
			bash install-RedHat.sh ${PARAMETERS}
		else
			curl -s -O http://download.onlyoffice.com/install/install-RedHat.sh
			bash install-RedHat.sh ${PARAMETERS}
			rm install-RedHat.sh
		fi
	elif [ -f /etc/debian_version ] ; then
		if [ "${LOCAL_SCRIPTS}" == "true" ]; then
			bash install-Debian.sh ${PARAMETERS}
		else
			curl -s -O http://download.onlyoffice.com/install/install-Debian.sh
			bash install-Debian.sh ${PARAMETERS}
			rm install-Debian.sh
		fi
	else
		echo "Not supported OS";
		exit 1;
	fi
fi
