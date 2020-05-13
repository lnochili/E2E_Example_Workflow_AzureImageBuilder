#!/bin/bash

#Install Node and npm
apt update
apt install nodejs
apt install npm

echo "Nodejs version is: "

nodejs --version

#create myapp directory only if does not exist

if [!-d /var/www/myapp]; 
then
    mkdir -p /var/www/myapp;
fi;
exit (0)
