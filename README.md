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





########################### Portainer #############################

mkdir portainer && cd portainer

apt install curl -y

curl -sL  https://raw.githubusercontent.com/techeAI/appscripts/main/portainer/setup_portainer.sh -o setup_portainer.sh && bash setup_portainer.sh




########################### Plex #############################

mkdir plex && cd plex

apt install curl -y

curl -sL  https://raw.githubusercontent.com/techeAI/appscripts/main/plex/setup_plex.sh -o setup_plex.sh && bash setup_plex.sh




########################### Pihole #############################

mkdir pihole && cd pihole

apt install curl -y

curl -sL  https://raw.githubusercontent.com/techeAI/appscripts/main/pihole/setup_pihole.sh -o setup_pihole.sh && bash setup_pihole.sh




########################### myDesktop #############################

mkdir myDesktop && cd myDesktop

apt install curl -y

curl -sL  https://raw.githubusercontent.com/techeAI/appscripts/main/mydesktop/setup_mydesktop.sh -o setup_mydesktop.sh && bash setup_mydesktop.sh



########################### Jitsi #############################

mkdir jitsi && cd jitsi

apt install curl -y

curl -sL  https://raw.githubusercontent.com/techeAI/appscripts/main/jitsi/jitsi.sh -o jitsi.sh && bash jitsi.sh




########################### Calcom #############################

mkdir calcom && cd calcom

apt install curl -y

curl -sL  https://raw.githubusercontent.com/techeAI/appscripts/main/calcom/calcom.sh -o calcom.sh && bash calcom.sh






########################### Paperless-NGX #############################


bash -c "$(curl -L https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/main/install-paperless-ngx.sh)"



########################### Antivirus (ClamAV) #############################

mkdir clam && cd clamav

apt install curl -y

curl -sL  https://raw.githubusercontent.com/techeAI/appscripts/main/antivirus/clam.sh -o clam.sh && bash clam.sh



########################### Handbrake #############################

mkdir handbrake && cd handbrake

apt install curl -y

curl -sL  https://raw.githubusercontent.com/techeAI/appscripts/main/handbrake/setup_handbrake.sh -o setup_handbrake.sh && bash setup_handbrake.sh



########################### OnlyOffice-Workspace #############################

mkdir onlyoffice-workspace && cd onlyoffice-workspace

apt install curl -y

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/OnlyOffice/workspace-install.sh -o workspace-install.sh && bash workspace-install.sh -ims false



########################### Cockpit #############################

mkdir cockpit && cd cockpit
apt install curl -y

curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/cockpit/cockpit.sh -o cockpit.sh && bash cockpit.sh





########################### Proxmox(PVE) Helper Scripts ###########################


Visit Website: https://tteck.github.io/Proxmox/

Zamba LXC Toolbox : https://github.com/bashclub/zamba-lxc-toolbox/

Virtualize Everything scripts: https://virtualizeeverything.com/

Virtualize Everything Video: https://www.youtube.com/watch?v=qa2Q7tZVol8/

Linux Containers: https://pve.proxmox.com/wiki/Linux_Container#pct_settings/

Removing Subscription error message from PVE

wget -qO remove_subscription_error.sh https://svastir-signature.s3.amazonaws.com/openTeche/PVE/remove_subscription_error.sh && bash remove_subscription_error.sh

Passthrough Physical Disk to Virtual Machine (VM)
For instructions, visit: https://pve.proxmox.com/wiki/Passthrough_Physical_Disk_to_Virtual_Machine_(VM)

Spinning down disks in PVE (when idle)
wget -qO setup_spindown.sh https://openteche.s3.amazonaws.com/TecheOS/spin_down_disks/setup_spindown.sh && bash setup_spindown.sh

Enabling IOMMU (For Intel CPU)

wget -qO enable_iommu_1.sh https://svastir-signature.s3.amazonaws.com/openTeche/PVE/enable_iommu_1.sh && bash enable_iommu_1.sh

Run the below script after reboot.

wget -qO enable_iommu_2.sh https://svastir-signature.s3.amazonaws.com/openTeche/PVE/enable_iommu_2.sh && bash enable_iommu_2.sh
