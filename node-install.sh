!#/bin/bash
#Install Node and npm

apt-get -y  update
curl -sL https://deb.nodesource.com/setup_12.x | bash -
apt-get install -y nodejs
apt-get  install -y npm
set print_text='Nodejs version is:' 
echo $print_text
nodejs --version
set print_text='npm version is:'
echo $print_text
npm --version

if [ ! -d /var/www/myapp ]; 
then
    mkdir -p /var/www/myapp;
fi;

