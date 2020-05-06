#!/bin/bash

#Install Node and npm
"echo 'packer' | sudo -S apt update
"echo 'packer' | sudo -S apt install nodejs
"echo 'packer' | sudo -S apt install npm

echo "Nodejs version is: "
"echo 'packer' | sudo -S nodejs --version

"echo 'packer' | sudo -S mkdir /var/www/myapp
