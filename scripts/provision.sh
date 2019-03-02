#!/bin/sh

# Setting up system
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install unzip -y

#installing nginx
sudo apt install nginx -y

#installing mysql
sudo apt install mysql-server -y

sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';"
sudo mysql -proot -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -proot -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -proot -e "DROP DATABASE IF EXISTS test;"
sudo mysql -proot -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql -proot -e "FLUSH PRIVILEGES;"

#installing php
sudo apt install php-fpm php-mysql php-xml php-intl php-json -y

#configuring nginx
sudo cp /install_files/localhost /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/
sudo unlink /etc/nginx/sites-enabled/default
sudo systemctl reload nginx

#Installing composer
cd ~
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

#configuring website
cd /var/www/html/
sudo chmod -R 777 .
rm -rf *
git clone https://github.com/MaxandreOgeret/lessn.git .
composer install
