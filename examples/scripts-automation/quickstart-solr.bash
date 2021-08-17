#!/bin/bash

RED='\033[0;31m';
GREEN='\033[0;32m';
NC='\033[0m';
bold=$(tput bold)
normal=$(tput sgr0)

# Import enviroment variables.
set -o allexport;
source ./examples/enviroment/.solr.env;
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

# Create solr_config directory.
printf "\n${GREEN}${bold}Create solr_config directory...\n\n${NC}";
mkdir $DRUPAL_ROOT_DIR/solr_config;

# Up project
printf "\n${GREEN}${bold}Run docker-compose up...\n\n${NC}";
docker-compose up --build -d --remove-orphans;

# Install drush, search_api_solr, devel to drupal project
printf "\n${GREEN}${bold}Install drush, search_api_solr, devel to drupal project...\n\n${NC}";
webserver_exec composer require drush/drush drupal/devel drupal/search_api_solr;

# Install drupal.
printf "\n${GREEN}${bold}Run drush site:install...\n\n${NC}";
webserver_exec drush si standard --account-pass=admin --site-name='Drupal' -y;


# Enable modules.
printf "\n${GREEN}${bold}Enable devel_generate and search_api_solr modules...\n\n${NC}";
webserver_exec drush en devel_generate search_api_solr search_api_solr_admin -y;

# Import search api configs to drupal.
printf "\n${GREEN}${bold}Import search api configs to drupal...\n\n${NC}";
mkdir $DRUPAL_ROOT_DIR/$DRUPAL_WEB_ROOT/solr_drupal_configs
cp ./examples/drupal_search_api_solr_configs/* $DRUPAL_ROOT_DIR/$DRUPAL_WEB_ROOT/solr_drupal_configs/
webserver_exec drush config:import --diff --partial --source=solr_drupal_configs -y;

# Create solr core.
printf "\n${GREEN}${bold}Generate solr core...\n\n${NC}";
webserver_exec drush solr-gsc solr config.zip 8.9 -y;
webserver_exec unzip -n $DRUPAL_WEB_ROOT/config.zip -d solr_config;


# Rebuild containers.
printf "\n${GREEN}${bold}Rebuild containers...\n\n${NC}";
docker-compose up --build -d --remove-orphans;


printf "\n${GREEN}${bold}Create solr core...\n\n${NC}";
docker-compose exec solr solr create -c drupal -d /drupal_conf

# Generate random nodes and indexing by search api.
printf "\n${GREEN}${bold}Generate random nodes...\n\n${NC}";
webserver_exec drush devel-generate:content -y

printf "\n${GREEN}${bold}Drupal installation complete.\n${NC}"
printf "   ${normal}Open ${bold}http://localhost ${normal}to see installed Drupal site\n${NC}";
printf "   ${normal}Open ${bold}http://localhost:8983 ${normal}to see Solr UI\n${NC}";
printf "   ${normal}Run ${bold}docker exec drupal_webserver_1 drush sapi-search node Dolore
      ${normal}to see working search api\n\n${NC}";
printf "   ${normal}To down containes run ${bold}docker-compose --env-file examples/enviroment/.solr.env down${normal}\n\n${NC}";
