apt install nginx nginx-common -y
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/nginx-ui/websrv-nginx.conf -o websrv-nginx.conf
url=$(grep "^nginxui_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
sed -i "s|prefixwebsrv.domainname|$url|g" ./websrv-nginx.conf
mv websrv-nginx.conf /etc/nginx/sites-available/websrv
ln -s /etc/nginx/sites-available/websrv /etc/nginx/sites-enabled/websrv
bash <(curl -L -s https://raw.githubusercontent.com/0xJacky/nginx-ui/master/install.sh) install

#http://your-server-ip:9000
#