#!/usr/bin/env bash
### Description: Install Azuracast (Ansible Installation)
### OS: Ubuntu 22.04 LTS
###
### ---READ---
### I understand the need of Supervisor for Azuracast. It will surely help some users.
### In my case i using this great product with another integration and need full control over MariaDB and Nginx.
###
### DO NOT USE THIS INSTALLER OR BRANCH. IT WILL NOT WORKING ON YOUR SIDE!
### ---READ---
###
### INSTALL
### cd /root && wget -q https://raw.githubusercontent.com/scysys/AzuraCast/scy/install_ansible_modified.sh && chmod +x install_ansible_modified.sh && ./install_ansible_modified.sh

##############################################################################
# Install AzuraCast for my needs
##############################################################################
# Ansible Installation
apt update && apt upgrade -y
apt install -q -y git

mkdir -p /var/azuracast/www
cd /var/azuracast/www

git clone https://github.com/scysys/AzuraCast.git .
git checkout -q -f scy

chmod a+x install.sh
./install.sh

# Remove from Supervisor
rm -f /etc/supervisor/conf.d/nginx.conf
rm -f /etc/supervisor/conf.d/mariadb.conf
supervisorctl reread # no need because of reboot

# Enable Services
systemctl enable nginx
systemctl enable mariadb

# Reboot System
reboot
