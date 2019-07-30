#!/bin/sh

# Setting up system
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/PostgreSQL.list'
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install unzip -y
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo service ssh restart

#installing nginx
sudo apt install nginx -y

#installing postgres
sudo apt install -y postgresql-11
sudo -u postgres createuser lessn -D -R -S
sudo -u postgres psql -c "ALTER USER lessn WITH PASSWORD 'lessn';"
sudo -u postgres psql -c "CREATE DATABASE lessn WITH OWNER 'lessn' ENCODING 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8' TEMPLATE template0;"
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/11/main/postgresql.conf
sudo sed -i "s/host    all             all             127.0.0.1\/32            md5/host    all             all            0.0.0.0\/0            md5/g" /etc/postgresql/11/main/pg_hba.conf
sudo systemctl restart postgresql

#installing php
sudo apt install php-fpm php-pgsql php-xml php-intl php-json php-curl php-mbstring -y

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
rm -rf /var/www/html/*
git clone https://github.com/MaxandreOgeret/lessn.git .
composer install

sudo -u postgres psql -d lessn -f sql/getChecksum.sql
sudo -u postgres psql -d lessn -f sql/applySbUpdate.sql

php bin/console do:sc:up --force

sudo chmod -R 777 .git/ var/