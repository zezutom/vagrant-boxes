#!/usr/bin/env bash

VERSION=5.6
ADMIN_PWD=root

echo "Installing MySQL 5.6"
sudo debconf-set-selections <<< 'mysql-server-'"$VERSION"' mysql-server/root_password password '"$ADMIN_PWD"''
sudo debconf-set-selections <<< 'mysql-server-'"$VERSION"' mysql-server/root_password_again password '"$ADMIN_PWD"''
sudo apt-get -y install mysql-server-"$VERSION"

echo "Enabling remote access"
for flag in {skip-external-locking,bind-address}
do
  sudo sed -i.bak "s/$flag/#$flag/g" /etc/mysql/my.cnf
done

echo "Restarting mysql service"
sudo service mysql restart

echo "Granting privileges"
mysql -u root -proot -Bse "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';" 

