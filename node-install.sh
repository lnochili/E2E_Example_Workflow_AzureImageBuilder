#!/bin/bash

#Install Node and npm
echo 'packer' | sudo -S apt update
echo 'packer' | sudo -S apt install nodejs
echo 'packer' | sudo -S apt install npm

echo "Nodejs version is: 

nodejs --version

echo 'packer' | sudo -S mkdir /var/www/myapp
exit(0)
