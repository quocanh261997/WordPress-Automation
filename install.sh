#!/bin/bash
#Name: Quoc Anh Nguyen
#Class: CSE470G

export DEBIAN_FRONTEND=noninteractive;
apt-get -y update;
apt-get install -y curl && apt-get install -y nano;

#Install tzdata for time zone setting
apt-get install -y tzdata;
ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime;
dpkg-reconfigure --frontend noninteractive tzdata;

#Install LAMP stack
#Install Apache2
apt-get update -y && apt-get install -y apache2
my_ip_address=$(curl -s http://ceclnx01.cec.miamioh.edu/ip.php)
echo "ServerName ${my_ip_address}" >> /etc/apache2/apache2.conf
echo "<Directory /var/www/html/>
	AllowOverride All
      </Directory>" >> /etc/apache2/apache2.conf
a2enmod rewrite
/etc/init.d/apache2 restart
/etc/init.d/apache2 status

#Install MYSQL and copy databases file
MYSQL_PW="A123456"
echo debconf mysql-server/root_password password ${MYSQL_PW} | debconf-set-selections;
echo debconf mysql-server/root_password_again password ${MYSQL_PW} | debconf-set-selections;
apt-get install -y mysql-server
/etc/init.d/mysql start
mysql --user="root" --password=${MYSQL_PW} -e "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql --user="root" --password=${MYSQL_PW} -e "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'password';"
mysql --user="root" --password=${MYSQL_PW} -e "FLUSH PRIVILEGES;"
mysql --user="root" --password=${MYSQL_PW} wordpress < wordpress.sql

#Install PHP
apt-get update -y
apt-get install -y php libapache2-mod-php php-mysql
sed -i "s/DirectoryIndex.*/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/" /etc/apache2/mods-enabled/dir.conf
/etc/init.d/apache2 restart
/etc/init.d/apache2 status

#Install WordPress
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
touch /tmp/wordpress/.htaccess
chmod 660 /tmp/wordpress/.htaccess
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
cp -a /tmp/wordpress/. /var/www/html
chown -R root:www-data /var/www/html
find /var/www/html -type d -exec chmod g+s {} \;
chmod g+w /var/www/html/wp-content
chmod -R g+w /var/www/html/wp-content/themes
chmod -R g+w /var/www/html/wp-content/plugins
sed -i "s/define('DB_NAME'.*/define('DB_NAME', 'wordpress');/" /var/www/html/wp-config.php
sed -i "s/define('DB_USER'.*/define('DB_USER', 'wordpressuser');/" /var/www/html/wp-config.php
sed -i "s/define('DB_PASSWORD'.*/define('DB_PASSWORD', 'password');/" /var/www/html/wp-config.php
echo "define('FS_METHOD', 'direct');" >> /var/www/html/wp-config.php 
