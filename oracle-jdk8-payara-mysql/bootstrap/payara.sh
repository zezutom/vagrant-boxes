#!/usr/bin/env bash

### Payara 4.1 ###
PAYARA_DIR="payara41"
INSTALL_DIR="/opt/$PAYARA_DIR"
if [ ! -d "$INSTALL_DIR" ]; then
  echo "Installing Payara 4.1.1"
  VERSION=4.1.1.171.1
  ZIP_ARCHIVE="$PAYARA_DIR.zip"
  sudo apt-get -y install unzip
  wget -O "$ZIP_ARCHIVE" http://search.maven.org/remotecontent?filepath=fish/payara/distributions/payara/"$VERSION"/payara-"$VERSION".zip
  unzip ./$ZIP_ARCHIVE
  mv ./$PAYARA_DIR /opt/
  rm ./$ZIP_ARCHIVE
fi

echo "Enabling Secure Admin to access the DAS remotely"
ADMIN_USER=admin
ADMIN_PASSWORD=admin

function create_password_file {
  sudo touch $1
  sudo chown vagrant:vagrant $1
  chmod 777 $1
  echo -e $2 >> $1
}

echo ".. creating tmp file"
TMP_FILE=/opt/tmpfile
create_password_file $TMP_FILE "AS_ADMIN_PASSWORD=\nAS_ADMIN_NEWPASSWORD=$ADMIN_PASSWORD"

echo ".. creating pwd file"
PWD_FILE=/opt/pwdfile
create_password_file $PWD_FILE "AS_ADMIN_PASSWORD=$ADMIN_PASSWORD"

echo ".. restarting domain"
ASADMIN_CMD=$INSTALL_DIR/bin/asadmin

$ASADMIN_CMD start-domain && \
$ASADMIN_CMD --user $ADMIN_USER --passwordfile="$TMP_FILE" change-admin-password && \
$ASADMIN_CMD --user $ADMIN_USER --passwordfile="$PWD_FILE" enable-secure-admin && \
$ASADMIN_CMD restart-domain

echo ".. cleaning up"
rm $TMP_FILE
