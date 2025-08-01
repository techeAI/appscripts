## Install common packages
sudo apt update -y
apt install htop curl snapd zabbix-agent -y
apt-get remove certbot
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

## install antivirus
apt install clamav clamav-daemon -y
systemctl stop clamav-freshclam
freshclam
systemctl start clamav-freshclam
systemctl enable --now clamav-daemon

#Deploy Nginx and nginx-UI
#mkdir -p /mnt/DriveDATA/Deploy-config/nginx && cd /mnt/DriveDATA/Deploy-config/nginx
#curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/nginx-ui/setup-nginxui.sh -o setup-nginxui.sh && bash setup-nginxui.sh

Deploy DASHBOARD
mkdir -p /mnt/DriveDATA/Deploy-config/DASHBOARD && cd /mnt/DriveDATA/Deploy-config/DASHBOARD
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/dashboard/setup_dashboard.sh -o setup_dashboard.sh && bash setup_dashboard.sh

## Deploy Portainer
mkdir /mnt/DriveDATA/Deploy-config/portainer && cd /mnt/DriveDATA/Deploy-config/portainer
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/portainer/setup_portainer.sh -o setup_portainer.sh && bash setup_portainer.sh

## Install Headscale
#mkdir /mnt/DriveDATA/Deploy-config/headscale && cd /mnt/DriveDATA/Deploy-config/headscale
#curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/headscale/setup_headscale.sh -o setup_headscale.sh && bash setup_headscale.sh

## Install Keycloak
#mkdir /mnt/DriveDATA/Deploy-config/keyclock && cd /mnt/DriveDATA/Deploy-config/keyclock
#curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/keyclock-oauth/setup_keyclock.sh -o  setup_keyclock.sh && bash setup_keyclock.sh

## Install Zabbix
mkdir /mnt/DriveDATA/Deploy-config/zabbix && cd /mnt/DriveDATA/Deploy-config/zabbix
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/zabbix/zabbix-docker.sh -o zabbix-docker.sh && bash zabbix-docker.sh

## Install mySPeed
mkdir /mnt/DriveDATA/Deploy-config/myspeed && cd /mnt/DriveDATA/Deploy-config/myspeed
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/myspeed/setup-myspeed.sh -o setup-myspeed.sh && bash setup-myspeed.sh

## Install Prom+grafana
#mkdir /mnt/DriveDATA/Deploy-config/prom-grafana && cd /mnt/DriveDATA/Deploy-config/prom-grafana
#curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/prom-grafana/setup_prom-grafana.sh -o  setup_prom-grafana.sh && bash setup_prom-grafana.sh

###################### Other Apps ################
## Install Nextcloud with onlyoffice
mkdir /mnt/DriveDATA/Deploy-config/nextcloud-oo && cd /mnt/DriveDATA/Deploy-config/nextcloud-oo
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mycloud-oo/setup_mycloud.sh -o setup_mycloud.sh && bash setup_mycloud.sh

## Install SuiteCRM
mkdir /mnt/DriveDATA/Deploy-config/suitecrm && cd /mnt/DriveDATA/Deploy-config/suitecrm
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/suitecrm/setup_suitecrm.sh -o setup_suitecrm.sh && bash setup_suitecrm.sh

## Install Odoo CRM
mkdir /mnt/DriveDATA/Deploy-config/odoo  && cd /mnt/DriveDATA/Deploy-config/odoo
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/odoo/setup-odoo.sh -o setup-odoo.sh && bash setup-odoo.sh

## Insatll Paperless NGX
mkdir /mnt/DriveDATA/Deploy-config/paperless-ngx && cd /mnt/DriveDATA/Deploy-config/paperless-ngx
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/paperless-ngx/setup_ngx.sh -o setup_ngx.sh && bash setup_ngx.sh

## Insatll Mattermost
mkdir /mnt/DriveDATA/Deploy-config/mattermost && cd /mnt/DriveDATA/Deploy-config/mattermost
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mattermost/setup-mattermost.sh -o setup-mattermost.sh && bash setup-mattermost.sh

## Insatll HRMS
mkdir /mnt/DriveDATA/Deploy-config/HRMS && cd /mnt/DriveDATA/Deploy-config/HRMS
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/HRMS/setup_hrms.sh -o setup_hrms.sh && bash setup_hrms.sh

## Insatll Focalboard
mkdir /mnt/DriveDATA/Deploy-config/focalboard && cd /mnt/DriveDATA/Deploy-config/focalboard
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/focalboard/setup_focalboard.sh -o setup_focalboard.sh && bash setup_focalboard.sh

## Install Opnform
mkdir /mnt/DriveDATA/Deploy-config/opnform && cd /mnt/DriveDATA/Deploy-config/opnform
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/opnform/setup_opnform.sh -o setup_opnform.sh && bash setup_opnform.sh

## Install n8n
mkdir /mnt/DriveDATA/Deploy-config/n8n && cd /mnt/DriveDATA/Deploy-config/n8n
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/n8n/setup_n8n.sh -o setup_n8n.sh && bash setup_n8n.sh

## Install OpenProject
mkdir /mnt/DriveDATA/Deploy-config/openproject && cd /mnt/DriveDATA/Deploy-config/openproject
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/openproject/setup_openproject.sh -o setup_openproject.sh && bash setup_openproject.sh

## Install Mautic
mkdir /mnt/DriveDATA/Deploy-config/mautic && cd /mnt/DriveDATA/Deploy-config/mautic
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mautic/setup_mautic.sh -o setup_mautic.sh && bash setup_mautic.sh

## Install Mantis BT
mkdir /mnt/DriveDATA/Deploy-config/techeBT && cd /mnt/DriveDATA/Deploy-config/techeBT
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/MantisBT/setup_bugtracker.sh -o setup_bugtracker.sh && bash setup_bugtracker.sh

## Install chatwoot
mkdir /mnt/DriveDATA/Deploy-config/chatwoot && cd /mnt/DriveDATA/Deploy-config/chatwoot
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/chatwoot/setup_chatwoot.sh -o setup_chatwoot.sh && bash setup_chatwoot.sh

## Install docuseal
mkdir /mnt/DriveDATA/Deploy-config/docuseal && cd /mnt/DriveDATA/Deploy-config/docuseal
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/docuseal/setup_docuseal.sh -o setup_docuseal.sh && bash setup_docuseal.sh

## Install Bookstack
mkdir /mnt/DriveDATA/Deploy-config/bookstack && cd /mnt/DriveDATA/Deploy-config/bookstack
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/bookstack/setup_bookstack.sh -o setup_bookstack.sh && bash setup_bookstack.sh

## Install Akaunting
mkdir /mnt/DriveDATA/Deploy-config/akaunting && cd /mnt/DriveDATA/Deploy-config/akaunting
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/akaunting/setup_akaunting.sh -o setup_akaunting.sh && bash setup_akaunting.sh

## Install Sterling PDF
mkdir /mnt/DriveDATA/Deploy-config/pdfeditor && cd /mnt/DriveDATA/Deploy-config/pdfeditor
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/stirling-pdf/stirling-pdf.sh -o stirling-pdf.sh && bash stirling-pdf.sh 

## Install Mesh Central
mkdir /mnt/DriveDATA/Deploy-config/meshcentral && cd /mnt/DriveDATA/Deploy-config/meshcentral
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mesh-central/setup-meshcentral.sh -o setup-meshcentral.sh && bash setup-meshcentral.sh

## InsInstall Snipe-IT
mkdir /mnt/DriveDATA/Deploy-config/snipe-it && cd /mnt/DriveDATA/Deploy-config/snipe-it
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/snipe-it/setup_snipe.sh -o setup_snipe.sh && bash setup_snipe.sh

## Install Filegator
mkdir /mnt/DriveDATA/Deploy-config/filegator && cd /mnt/DriveDATA/Deploy-config/filegator
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/filegator/setup-filegator.sh -o setup_filegator.sh && bash setup_filegator.sh

## Install Search
mkdir /mnt/DriveDATA/Deploy-config/search && cd /mnt/DriveDATA/Deploy-config/search
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/whoogle/setup_whoogle.sh -o setup_whoogle.sh && bash setup_whoogle.sh

## Install Immich
mkdir /mnt/DriveDATA/Deploy-config/immich && cd /mnt/DriveDATA/Deploy-config/immich
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/immich/setup_immich.sh -o setup_immich.sh && bash setup_immich.sh

## Install Nocodedb
mkdir /mnt/DriveDATA/Deploy-config/nocodb && cd /mnt/DriveDATA/Deploy-config/nocodb
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/NoCoDB/setup-nocodb.sh -o setup-nocodb.sh && bash setup-nocodb.sh

## Install Docmost
mkdir /mnt/DriveDATA/Deploy-config/docmost && cd /mnt/DriveDATA/Deploy-config/docmost
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/docmost/setup_docmost.sh -o setup_docmost.sh && bash setup_docmost.sh

## Install Vaultwarden
mkdir /mnt/DriveDATA/Deploy-config/vaultwarden && cd /mnt/DriveDATA/Deploy-config/vaultwarden
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/vaultwarden/setup_vaultwarden.sh -o setup_vaultwarden.sh && bash setup_vaultwarden.sh

## Install ITtools
mkdir /mnt/DriveDATA/Deploy-config/ittools && cd /mnt/DriveDATA/Deploy-config/ittools
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/it-tools/setup-ittools.sh -o setup-ittools.sh && bash setup-ittools.sh

## Install Mindmap
mkdir /mnt/DriveDATA/Deploy-config/mindmap && cd /mnt/DriveDATA/Deploy-config/mindmap
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/mindmap-wisemap/setup-mindmap.sh -o setup-mindmap.sh && bash setup-mindmap.sh

## Replace URLs in Dashboard
# Maestro Get URLS from urls.conf   
nginx_url=$(grep "^nginxui_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
dashboard_url=$(grep "^dashboard_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
vitals_url=$(grep "^vitals_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
portainer_url=$(grep "^portainer_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
headscale_url=$(grep "^headscale_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
keycloak_url=$(grep "^keycloak_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
zabbix_url=$(grep "^zabbix_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
myspeed_url=$(grep "^myspeed_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
prometheus_url=$(grep "^prometheus_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
grafana_url=$(grep "^grafana_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
# Other APps URL from urls.conf
Nextcloud_OO=$(grep "^Nextcloud_OO=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
suite_CRM=$(grep "^suite_CRM=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
odoo_CRM=$(grep "^odoo_CRM=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
paperless_ngx_url=$(grep "^paperless_ngx_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d"=" -f2)
mattermost_URL=$(grep "^mattermost_URL=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
hrms_url=$(grep "^hrms_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
focalboard_url=$(grep "^focalboard_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
opnform_url=$(grep "^opnform_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
n8n_url=$(grep "^n8n_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
openproject_url=$(grep "^openproject_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
mautic_url=$(grep "^mautic_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
mantisBT_url=$(grep "^mantisBT_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
chatwoot_url=$(grep "^chatwoot_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
docuseal_url=$(grep "^docuseal_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
bookstack_url=$(grep "^bookstack_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
akaunting_url=$(grep "^akaunting_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
sterlingpdf_url=$(grep "^sterlingpdf_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
meshcentral_url=$(grep "^meshcentral_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
snipeit_url=$(grep "^snipeit_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
filegator_url=$(grep "^filegator_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
whoogle_url=$(grep "^whoogle_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
immich_url=$(grep "^immich_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
nocodedb_url=$(grep "^nocodedb_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
docmost_url=$(grep "^docmost_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
vaultwarden_url=$(grep "^vaultwarden_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
ittools_url=$(grep "^ittools_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
mindmap_url=$(grep "^mindmap_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
## Find and replace URL in /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/websrv/$nginx_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/vital/$vitals_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/apps/$portainer_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/net/$headscale_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/auth/$keycloak_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/monitor/$zabbix_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/speed/$myspeed_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/grafana/$grafana_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
# Other App Urls
sed -i "/\(url\|externalUrl\)/s/mycloud_biztech/$Nextcloud_OO/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/crm/$suite_CRM/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/odoo/$odoo_CRM/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/docs/$paperless_ngx_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/mattermost/$mattermost_URL/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/hr/$hrms_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/board/$focalboard_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/forms/$opnform_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/flow/$n8n_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/projects/$openproject_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/mautic/$mautic_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/tickets/$mantisBT_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/chat/$chatwoot_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/esign/$docuseal_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/books/$bookstack_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/accounts/$akaunting_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/pdf/$sterlingpdf_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/mesh/$meshcentral_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/digiassets/$snipeit_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/vault/$filegator_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/search/$whoogle_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/photos/$immich_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/tables/$nocodedb_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/wiki/$docmost_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/pass/$vaultwarden_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/ittools/$ittools_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json
sed -i "/\(url\|externalUrl\)/s/mind/$mindmap_url/g" /mnt/DriveDATA/DASHBOARD/teche-dashboard_configs/default.json