####################### Installing DASHBOARD #######################

Run below command in bash shell.

mkdir dashboard && cd dashboard

apt install curl -y

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/dashboard/setup_homarr.sh -o setup_homarr.sh && bash setup_homarr.sh






########################### Zabbix #############################

mkdir zabbix && cd zabbix

apt install curl -y

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/zabbix/zabbix-docker.sh -o zabbix-docker.sh && bash zabbix-docker.sh






########################### Urbackup #############################

mkdir Urbackup && cd Urbackup

apt install curl -y

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/urbackup/setup_urbackup.sh -o setup_urbackup.sh && bash setup_urbackup.sh

