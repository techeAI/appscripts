#!/bin/bash

set -e
set -x

### VARIABLES

DB_NAME="suitecrm"
DB_USER="suitecrmuser"
DB_PASS="StrongPassword123"
INSTALL_DIR="/var/www/suitecrm"
DOWNLOAD_URL="https://suitecrm.com/download/166/suite89/567686/suitecrm-8-9-3.zip"

echo "🔄 Updating system..."
apt update && apt upgrade -y

echo "📦 Installing dependencies..."
apt install -y apache2 mariadb-server unzip wget curl

echo "🐘 Installing PHP (Debian 12 default PHP 8.2)..."
apt install -y php php-cli php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-bcmath php-intl libapache2-mod-php php-soap php-ldap php-imap

echo "⚙️ Configuring PHP (Apache)..."

PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
PHPINI="/etc/php/${PHP_VERSION}/apache2/php.ini"

sed -i 's/memory_limit = .*/memory_limit = 512M/' $PHPINI
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 50M/' $PHPINI
sed -i 's/post_max_size = .*/post_max_size = 50M/' $PHPINI
sed -i 's/max_execution_time = .*/max_execution_time = 300/' $PHPINI

systemctl restart apache2

echo "🛢️ Configuring MariaDB..."
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "⬇️ Downloading SuiteCRM..."
cd /var/www/
rm -f suitecrm.zip
wget ${DOWNLOAD_URL} -O suitecrm.zip

echo "📂 Extracting..."
rm -rf suitecrm_temp
mkdir suitecrm_temp
unzip suitecrm.zip -d suitecrm_temp
rm -f suitecrm.zip

echo "📦 Preparing install directory..."
rm -rf ${INSTALL_DIR}
mkdir -p ${INSTALL_DIR}

cp -r suitecrm_temp/* ${INSTALL_DIR}/
rm -rf suitecrm_temp

echo "🔐 Setting permissions..."
chown -R www-data:www-data ${INSTALL_DIR}
find ${INSTALL_DIR} -type d -exec chmod 755 {} \;
find ${INSTALL_DIR} -type f -exec chmod 644 {} \;

echo "⚙️ Creating .env file..."
if [ -f "${INSTALL_DIR}/.env.local" ]; then
cp ${INSTALL_DIR}/.env.local ${INSTALL_DIR}/.env
elif [ -f "${INSTALL_DIR}/.env.dist" ]; then
cp ${INSTALL_DIR}/.env.dist ${INSTALL_DIR}/.env
else
    echo "APP_ENV=prod" > ${INSTALL_DIR}/.env
    echo "APP_DEBUG=0" >> ${INSTALL_DIR}/.env
    echo "DATABASE_URL=\"mysql://${DB_USER}:${DB_PASS}@127.0.0.1:3306/${DB_NAME}\"" >> ${INSTALL_DIR}/.env
fi
chown www-data ${INSTALL_DIR}/.env
chmod 644 ${INSTALL_DIR}/.env

echo "🌐 Configuring Apache..."
cat <<EOL > /etc/apache2/sites-available/suitecrm.conf
<VirtualHost *:80>
    ServerName suitecrm.local
    DocumentRoot ${INSTALL_DIR}/public

    <Directory ${INSTALL_DIR}/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/suitecrm_error.log
    CustomLog \${APACHE_LOG_DIR}/suitecrm_access.log combined
</VirtualHost>
EOL
a2dissite 000-default.conf || true
a2ensite suitecrm.conf
a2enmod rewrite
systemctl reload apache2
echo "⏰ Setting cron job..."
(crontab -u www-data -l 2>/dev/null; echo "* * * * * cd ${INSTALL_DIR} && php bin/console suitecrm:cron:run > /dev/null 2>&1") | crontab -u www-data -

echo "🔥 Allowing HTTP (if firewall enabled)..."
ufw allow 80 || true

echo "🧪 Verifying installation..."
ls -la ${INSTALL_DIR}
ls -la ${INSTALL_DIR}/public || true

echo "✅ Installation completed!"
echo ""
echo "👉 Access: http://<VM-IP>"
echo "👉 DB Name: ${DB_NAME}"
echo "👉 DB User: ${DB_USER}"
echo "👉 DB Pass: ${DB_PASS}"
echo ""
echo "⚠️ Complete setup via browser"