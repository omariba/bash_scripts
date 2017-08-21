wget -O- http://debian.koha-community.org/koha/gpg.asc | apt-key add -
echo 'deb http://debian.koha-community.org/koha stable main' | tee /etc/apt/sources.list.d/koha.list
apt-get update
apt-get install koha-common

a2dismod mpm_event 
apt-get install -f
apt-get install apache2
apt-get install mysql-server

a2enmod rewrite 
a2enmod cgi 
service apache2 restart
