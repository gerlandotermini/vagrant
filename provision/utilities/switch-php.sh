#!/bin/bash

if [[ -z $1 ]]; then
  echo "Usage: switch-php phpver"
  exit
fi

CURRENT_PHP_VER=$(a2query -m | grep php | awk '{print $1}')

if [[ -z "$CURRENT_PHP_VER" ]]; then
  echo "No PHP module enabled. Aborting."
else
  sudo a2dismod "$CURRENT_PHP_VER"	
fi

sudo a2enmod $1
sudo update-alternatives --set php /usr/bin/$1
sudo systemctl restart apache2
