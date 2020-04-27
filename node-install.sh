#!/bin/bash

#Install Node and npm
sudo apt update
sudo apt install nodejs
sudo apt install npm

echo "Nodejs version is: "
nodejs --version

cd /var/www/myapp
sudo npm  init --force
