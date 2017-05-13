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

BOOTSTRAP_DIR=/vagrant/bootstrap

source $BOOTSTRAP_DIR/oracle_jdk.sh
source $BOOTSTRAP_DIR/payara.sh
source $BOOTSTRAP_DIR/mysql.sh
