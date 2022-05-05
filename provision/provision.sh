#!/usr/bin/env bash

# Vagrantfile will pass these variables to the provisioning script
WEB_HOSTNAME=$1
DB_HOSTNAME=$2
MAIL_HOSTNAME=$3

# Update all package repos
sudo add-apt-repository -y ppa:ondrej/php 2> /dev/null
sudo apt-get update

# Install make
sudo apt-get install -y make 2> /dev/null

# Install zip/unzip
sudo apt-get install -y zip 2> /dev/null

# Install NTP, to keep server date and time up-to-date
sudo apt-get install -y ntp
sudo timedatectl set-ntp on

# Install Apache 2.4
sudo apt-get install -y apache2

# Enable Apache modules
sudo a2enmod rewrite 2> /dev/null
sudo a2enmod ssl 2> /dev/null

# Setup Apache user and group in envvars
APACHEUSR=`grep -c 'APACHE_RUN_USER=www-data' /etc/apache2/envvars`
APACHEGRP=`grep -c 'APACHE_RUN_GROUP=www-data' /etc/apache2/envvars`
if [ APACHEUSR ]; then
	sudo sed -i 's/APACHE_RUN_USER=www-data/APACHE_RUN_USER=vagrant/' /etc/apache2/envvars
fi
if [ APACHEGRP ]; then
	sudo sed -i 's/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=vagrant/' /etc/apache2/envvars
fi
sudo chown -R vagrant:vagrant /var/lock/apache2

# Fix permissions on the .config folder
if [ -d /home/vagrant/.config ]; then
	sudo chown -R vagrant:vagrant /home/vagrant/.config
else
	mkdir /home/vagrant/.config
fi

# Install PHP 7.4
sudo apt-get install -y php7.4 php7.4-fpm php7.4-common php7.4-mysql php7.4-mysqli php7.4-xml libapache2-mod-php7.4 php7.4-cli php7.4-mbstring php7.4-xml php7.4-curl php7.4-zip php7.4-ldap php7.4-dom php7.4-opcache php7.4-gd

# Set PHP 7.4 as the default version for CLI and others
sudo update-alternatives --set php /usr/bin/php7.4

# Install Latest MySQL Server
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password vagrant'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vagrant'
sudo apt-get install -y mysql-server
sudo apt-get install -y mysql-client

# Install Node, NPM and Gulp
sudo apt-get install -y nodejs
sudo apt-get install -y npm
sudo npm install --global gulp-cli

# Install PHP Composer
sudo curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php 2> /dev/null
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer 2> /dev/null
sudo chown vagrant:vagrant /usr/local/bin/composer 2> /dev/null
sudo chown vagrant:vagrant /home/vagrant/.composer 2> /dev/null

# Install git
sudo apt-get install -y git

# Upgrade nodejs to v10.x
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

# Rebuilt the NPM database
sudo npm rebuild node-sass

# Install PhpMyAdmin
if [ ! -d /var/www/$DB_HOSTNAME/ ]; then
	mkdir /var/www/$DB_HOSTNAME/
	mkdir /var/www/$DB_HOSTNAME/html/
	mkdir /var/www/$DB_HOSTNAME/logs/

	echo "Installing PHPMyAdmin"
	composer create-project phpmyadmin/phpmyadmin /var/www/$DB_HOSTNAME/html/
	cd /var/www/$DB_HOSTNAME/html/
	composer update
fi

# Configure PhpMyAdmin
if [ -f /var/www/$DB_HOSTNAME/html/config.sample.inc.php ]; then
	mv /var/www/$DB_HOSTNAME/html/config.sample.inc.php /var/www/$DB_HOSTNAME/html/config.inc.php 2> /dev/null
fi

# Install virtual host for PhpMyAdmin
if [[ -f /provision/config/vhost && -d /etc/apache2/sites-available/ ]]; then
	sudo cp /provision/config/vhost /etc/apache2/sites-available/$DB_HOSTNAME.conf 2> /dev/null
	sudo sed -i "s/VH_SITEURL/$DB_HOSTNAME/g" /etc/apache2/sites-available/$DB_HOSTNAME.conf 2> /dev/null
	sudo ln -s /etc/apache2/sites-available/$DB_HOSTNAME.conf /etc/apache2/sites-enabled/$DB_HOSTNAME.conf 2> /dev/null
fi

# Generate private/public key pair
ssh-keygen -t rsa -N "" -f /home/vagrant/.ssh/id_rsa -C "vagrant@$WEB_HOSTNAME"
sudo chown vagrant:vagrant /home/vagrant/.ssh/id_rsa*

# Regenerate snakeoil SSL cert for Apache, making it OSX 10.15 compliant
sudo chown vagrant:vagrant /usr/share/ssl-cert/ssleay.cnf
sudo echo -e "extendedKeyUsage=1.3.6.1.5.5.7.3.1\nsubjectAltName=@alt_names\n[alt_names]\nDNS.1=$WEB_HOSTNAME\nDNS.2=$DB_HOSTNAME\n" >> /usr/share/ssl-cert/ssleay.cnf 2> /dev/null
sudo sed -i "s/days 3650/days 824/g"  /usr/sbin/make-ssl-cert 2> /dev/null
sudo make-ssl-cert generate-default-snakeoil --force-overwrite

# Install WP-CLI
sudo wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp 2> /dev/null
sudo chown vagrant:vagrant /usr/local/bin/wp
sudo chmod +x /usr/local/bin/wp 2> /dev/null

# Install bash aliases and WP-CLI autocompletion
if [ -f /provision/config/bash ]; then
	cp /provision/config/bash /home/vagrant/.bash_profile 2> /dev/null
fi

# Install Mailhog as a service
sudo wget https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64 -O /usr/local/bin/mailhog 2> /dev/null
sudo chown vagrant:vagrant /usr/local/bin/mailhog
sudo chmod +x /usr/local/bin/mailhog 2> /dev/null

if [ -f /provision/config/mailhog ]; then
	sudo cp /provision/config/mailhog /etc/systemd/system/mailhog.service 2> /dev/null
	VM_IP_ADDRESS=$(hostname -I | cut -f2 -d' ')
	sudo sed -i "s/GUEST_IP_ADDRESS/$VM_IP_ADDRESS/g" /etc/systemd/system/mailhog.service 2> /dev/null
	sudo systemctl enable mailhog 2> /dev/null
	sudo systemctl start mailhog
fi

# Configure PHP (both CLI and module) to use Mailhog
sudo sed -i "s/\;sendmail_path =/sendmail_path = \"\/usr\/local\/bin\/mailhog sendmail\"/" /etc/php/7.4/cli/php.ini 2> /dev/null
sudo sed -i "s/\;sendmail_path =/sendmail_path = \"\/usr\/local\/bin\/mailhog sendmail\"/" /etc/php/7.4/apache2/php.ini 2> /dev/null

# Increase limits in php.ini
sudo sed -i "s/post_max_size.*/post_max_size = 128M/g" /etc/php/7.4/apache2/php.ini 2> /dev/null
sudo sed -i "s/upload_max_filesize.*/upload_max_filesize = 128M/g" /etc/php/7.4/apache2/php.ini 2> /dev/null

# Configure the correct time zone
sudo rm /etc/localtime && sudo ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime

# Check for updates
sudo apt-get upgrade -y 2> /dev/null

# Prepare the post-install script
if [ -f /provision/utilities/wp-setup ]; then
	sudo ln -s /provision/utilities/wp-* /usr/local/bin/
	sudo chown vagrant:vagrant /usr/local/bin/wp-*
	sudo chmod u+x /usr/local/bin/wp-*
fi

# Install WordPress
source /usr/local/bin/wp-setup $WEB_HOSTNAME

# Remind the user a few useful things
echo -e "\n\nYou can now log into your newly minted virtual machine by typing: vagrant ssh.\033[0m\n\nUseful notes:"
echo "- Setup your git username and email: git config --global user.email \"user@host\"; git config --global user.name \"Full Name\""
echo "- Your SSH public key (to connect to Gitlab and other remote servers) is available under ~/.ssh/id_rsa.pub"
echo "- You can install this key on your server by using: ssh-copy-id -i ~/.ssh/id_rsa.pub \"user@host -p port\""
echo "- If your server uses a port other than 22 for SSH, you can configure your client accordingly via ~/.ssh/config"
echo "- You can initialize a new website by using the following script: wp-setup.sh your-site-name-here.local"
echo -e "\nFor more information, please refer to our online repository at https://gitlab.com/gccomms/vagrant. Enjoy!"