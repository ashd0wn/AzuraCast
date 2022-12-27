#!/usr/bin/env bash

PS3='Enter your choice: '
options=("Rebiuld frontend" "Pull changes and rebuild frontend" "Quit")
select opt in "${options[@]}"; do
  case $opt in
  "Rebiuld frontend")
    APP_ENV="${APP_ENV:-production}"
    UPDATE_REVISION="${UPDATE_REVISION:-94}"

    ansible-playbook util/ansible/azuracast-build.yml --inventory=util/ansible/hosts --extra-vars "app_env=$APP_ENV update_revision=$UPDATE_REVISION"
    break
    ;;
  "Pull changes and rebuild frontend")
    APP_ENV="${APP_ENV:-production}"
    UPDATE_REVISION="${UPDATE_REVISION:-94}"

    if [[ ${APP_ENV} == "production" ]]; then
      if [[ -d ".git" ]]; then
        git config --global --add safe.directory /var/azuracast/www
        git reset --hard
        git pull
      else
        echo "You are running a downloaded release build. Any code updates should be applied manually."
      fi
    fi

    ansible-playbook util/ansible/azuracast-build.yml --inventory=util/ansible/hosts --extra-vars "app_env=$APP_ENV update_revision=$UPDATE_REVISION"
    break
    ;;
  "Quit")
    break
    ;;
  *) echo "invalid option $REPLY" ;;
  esac
done
