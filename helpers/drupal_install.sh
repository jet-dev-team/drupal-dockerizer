#!/bin/bash

# Import enviroment variables.
set -o allexport
source ./$1
set +o allexport

# Set user uid and gid.
export USER_UID=`id -u`
export USER_GID=`id -g`

# Up project
docker-compose up --build -d --remove-orphans

webserver_exec () {
  docker-compose exec -e XDEBUG_MODE=off webserver $@
}

# Install drupal.
webserver_exec drush si standard --account-pass=admin --site-name='Drupal' -y
