apt install nginx nginx-common -y
curl -sL https://raw.githubusercontent.com/techeAI/appscripts/main/nginx-ui/websrv-nginx.conf -o websrv-nginx.conf
url=$(grep "^nginxui_url=" /mnt/DriveDATA/Deploy-config/urls.conf | cut -d'=' -f2)
sed -i "s|prefixwebsrv.domainname|$url|g" ./websrv-nginx.conf
mv websrv-nginx.conf /etc/nginx/sites-available/websrv
ln -s /etc/nginx/sites-available/websrv /etc/nginx/sites-enabled/websrv
bash <(curl -L -s https://raw.githubusercontent.com/0xJacky/nginx-ui/master/install.sh) install
sleep 5
INI_FILE="/usr/local/etc/nginx-ui/app.ini"

# Comment out any existing lines for AccessLogPath and ErrorLogPath
sed -i '/^\[nginx\]/,/^\[/{s/^\(AccessLogPath[ \t]*=\)/# \1/; s/^\(ErrorLogPath[ \t]*=\)/# \1/}' "$INI_FILE"

# Append new lines just after [nginx] section
awk -v access="/var/log/nginx/access.log" -v error="/var/log/nginx/error.log" '
    BEGIN { inserted=0 }
    /^\[nginx\]/ {
        print
        if (!inserted) {
            print "AccessLogPath   = " access
            print "ErrorLogPath    = " error
            inserted=1
        }
        next
    }
    { print }
' "$INI_FILE" > "${INI_FILE}.tmp" && mv "${INI_FILE}.tmp" "$INI_FILE"

systemctl restart nginx-ui

#http://your-server-ip:9000
#