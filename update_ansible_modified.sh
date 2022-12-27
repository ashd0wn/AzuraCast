#!/usr/bin/env bash
### Description: Update Azuracast (Ansible Installation)
### OS: Ubuntu 22.04 LTS
###
### This update script is needed when using the modified ansible installer "install_ansible_modified.sh". Without working supervisor, Azuracast updater will fail.
###
### Update
### cd /var/azuracast/www && wget -q https://raw.githubusercontent.com/scysys/AzuraCast/scy/update_ansible_modified.sh && chmod +x update_ansible_modified.sh && ./update_ansible_modified.sh

##############################################################################
# Update AzuraCast
##############################################################################
### Prepare
# Copy to Supervisor
cp /var/azuracast/www/util/ansible/roles/nginx/templates/supervisor.conf.j2 /etc/supervisor/conf.d/nginx.conf
cp /var/azuracast/www/util/ansible/roles/mariadb/templates/supervisor.conf.j2 /etc/supervisor/conf.d/mariadb.conf

# Chmod files
chmod 0644 /etc/supervisor/conf.d/nginx.conf
chmod 0644 /etc/supervisor/conf.d/mariadb.conf

# Supervisor
supervisorctl reread
supervisorctl restart all

### Azuracast Updater
while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do
  case $1 in
  --dev)
    APP_ENV="development"
    ;;

  --full)
    UPDATE_REVISION=0
    ;;
  esac
  shift
done
if [[ "$1" == '--' ]]; then shift; fi

. /etc/lsb-release

if [[ $DISTRIB_ID != "Ubuntu" ]]; then
  echo "Ansible installation is only supported on Ubuntu distributions."
  exit 0
fi

sudo apt-get update
sudo apt-get install -q -y software-properties-common

if [[ $DISTRIB_CODENAME == "focal" ]]; then
  sudo apt-get install -q -y ansible python3-pip python3-mysqldb
else
  sudo add-apt-repository -y ppa:ansible/ansible
  sudo apt-get update

  sudo apt-get install -q -y python2.7 python-pip python-mysqldb ansible
fi

APP_ENV="${APP_ENV:-production}"
UPDATE_REVISION="${UPDATE_REVISION:-94}"

echo "Updating AzuraCast (Environment: $APP_ENV, Update revision: $UPDATE_REVISION)"

if [[ ${APP_ENV} == "production" ]]; then
  if [[ -d ".git" ]]; then
    git config --global --add safe.directory /var/azuracast/www
    git reset --hard
    git pull
  else
    echo "You are running a downloaded release build. Any code updates should be applied manually."
  fi
fi

ansible-playbook util/ansible/update.yml --inventory=util/ansible/hosts --extra-vars "app_env=$APP_ENV update_revision=$UPDATE_REVISION"

### Final
# Remove from Supervisor
supervisorctl stop nginx
supervisorctl stop mariadb
rm -f /etc/supervisor/conf.d/nginx.conf
rm -f /etc/supervisor/conf.d/mariadb.conf
supervisorctl reread

# Restart Services
systemctl restart nginx
systemctl restart mariadb

echo "done"