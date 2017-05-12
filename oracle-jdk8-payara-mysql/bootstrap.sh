#!/usr/bin/env bash

###
#
# Installs Oracle JDK 8, Payara 4.1.1 and MySQL
#
# Courtesy:
# https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-get-on-ubuntu-16-04
# https://dzone.com/articles/vagrant
# http://stackoverflow.com/questions/42773521/secure-admin-must-be-enabled-to-access-the-das-remotely-acess-glassfish-admin
###

sudo apt-get update

### Oracle JDK 8 ###
echo "Installing Java 8"
sudo apt-get -y install software-properties-common python-software-properties
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
sudo apt-get -y install oracle-java8-installer
sudo apt-get -y install oracle-java8-set-default

### Payara 4.1 ###
echo "Installing Payara 4.1.1"
PAYARA_VERSION=4.1.1.171.1
sudo apt-get -y install unzip
wget -O "payara41.zip" http://search.maven.org/remotecontent?filepath=fish/payara/distributions/payara/"$PAYARA_VERSION"/payara-"$PAYARA_VERSION".zip
unzip ./payara41.zip 
mv ./payara41 /opt/

echo "Enabling Secure Admin to access the DAS remotely"
PAYARA_PATH=/opt/payara41
PAYARA_ADMIN_USER=admin
PAYARA_ADMIN_PASSWORD=admin

# Create file and make sure 'vagrant' user has full perms
function create_input_file {
  sudo touch $1
  sudo chown vagrant:vagrant $1
  chmod 777 $1  
}

echo ".. creating tmp file"
TMP_FILE=/opt/tmpfile
create_input_file tmpfile
echo -e "AS_ADMIN_PASSWORD=\nAS_ADMIN_NEWPASSWORD=$PAYARA_ADMIN_PASSWORD" >> $TMP_FILE 

echo ".. creating pwd file"
PWD_FILE=/opt/pwdfile
create_input_file pwdfile
echo -e "AS_ADMIN_PASSWORD=$PAYARA_ADMIN_PASSWORD" >> $PWD_FILE 

echo ".. restarting domain"
$PAYARA_PATH/bin/asadmin start-domain && \
$PAYARA_PATH/bin/asadmin --user $PAYARA_ADMIN_USER --passwordfile="$TMP_FILE" change-admin-password && \
$PAYARA_PATH/bin/asadmin --user $PAYARA_ADMIN_USER --passwordfile="$PWD_FILE" enable-secure-admin && \
$PAYARA_PATH/bin/asadmin restart-domain

echo ".. cleaning up"
rm $TMP_FILE

echo "Installing MySQL 5.6"
MYSQL_VERSION=5.6
MYSQL_ADMIN_PASSWORD=root
sudo debconf-set-selections <<< 'mysql-server-'"$MYSQL_VERSION"' mysql-server/root_password password '"$MYSQL_ADMIN_PASSWORD"''
sudo debconf-set-selections <<< 'mysql-server-'"$MYSQL_VERSION"' mysql-server/root_password_again password '"$MYSQL_ADMIN_PASSWORD"''
sudo apt-get -y install mysql-server-"$MYSQL_VERSION"
