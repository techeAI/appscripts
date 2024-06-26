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





########################### Synthing #############################

mkdir syncthing && cd syncthing

apt install curl -y

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/syncthing/setup_syncthing.sh -o setup_syncthing.sh && bash setup_syncthing.sh





########################### SuiteCRM #############################

mkdir suitecrm && cd suitecrm

apt install curl -y

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/suitecrm/setup_suitecrm.sh -o setup_suitecrm.sh && bash setup_suitecrm.sh




########################### Shinobi #############################

mkdir shinobi && cd shinobi

apt install curl -y

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/shinobi/setup_shinobi.sh -o setup_shinobi.sh && bash setup_shinobi.sh


