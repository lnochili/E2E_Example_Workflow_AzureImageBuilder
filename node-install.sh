!#/bin/bash
#Install Node and npm

apt-get -y  update
apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates
curl -sL https://deb.nodesource.com/setup_12.x | bash -
apt-get install -y nodejs
apt-get  install -y npm
echo 'Nodejs version is: ' `nodejs --version`
echo 'npm version is: ' `npm --version`

if [ ! -d /var/www/myapp ] 
then
    echo 'Creating directory'
    mkdir -p /var/www/myapp
fi

