#!/bin/bash

RED='\033[0;31m';
GREEN='\033[0;32m';
NC='\033[0m';
bold=$(tput bold)
normal=$(tput sgr0)

# Import enviroment variables.
set -o allexport;
source ./examples/enviroment/.quickstart.env;
set +o allexport;

# Set user uid and gid.
export USER_UID="${USER_UID:-`id -u`}";
export USER_GID="${USER_GID:-`id -g`}";

webserver_exec () {
  docker-compose exec -w /var/www/ -e XDEBUG_MODE=off webserver $@;
}

docker_composer () {
  docker run \
    --rm --interactive --tty --volume `pwd`:/app \
    --user $USER_UID:$USER_GID composer --no-cache --ignore-platform-reqs $@;
}

# Create drupal project by composer.
printf "\n${GREEN}${bold}Create-project drupal/recommended-project by composer...\n\n${NC}";
docker_composer create-project drupal/recommended-project $DRUPAL_ROOT_DIR;

# Up project
printf "\n${GREEN}${bold}Run docker-compose up...\n\n${NC}";
docker-compose up --build -d --remove-orphans;

# Install drush to drupal project
printf "\n${GREEN}${bold}Install drush to drupal project...\n\n${NC}";
webserver_exec composer require drush/drush;

# Install drupal.
printf "\n${GREEN}${bold}Run drush site:install...\n\n${NC}";
webserver_exec drush si standard --account-pass=admin --site-name='Drupal' -y;

# Create launch.json for debug in vscode.
printf "\n${GREEN}${bold}Create launch.json for debug in vscode.\n${NC}"
mkdir -p .vscode
cp ./examples/xdebug-vscode.json ./.vscode/launch.json

printf "\n${GREEN}${bold}Drupal installation complete.\n${NC}"
printf "   ${normal}Open ${bold}http://localhost ${normal}to see installed Drupal site\n${NC}";
printf "   ${normal}To down containes run ${bold}docker-compose --env-file examples/enviroment/.quickstart.env down${normal}\n\n${NC}"
