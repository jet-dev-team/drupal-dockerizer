# Availble options(vars) for drupal-dockerizer config

| Option | Description | Example |
| ------------ | ------------ | ------------ |
| compose_project_name | Name of your project. Its prefix for docker containers | drupal-project |
| docker_runtime_dir | Name for drupal-dockerizer runtime directory. You can up many projects from drupal-dokerizer directory. Ensure that all you project have different name | drupal-project-runtime |
| docker_cached_volume | Set option :cached for docker volume. [more](http://docs.docker.oeynet.com/docker-for-mac/osxfs-caching/). | false |
| user_uid | uid your user in system. Run `id -u` for see you uid | 1000 |
| user_gid | uid your user in system. Run `id -g` for see you uid | 1000 |
| drupal_root_dir | Absоlute path to your drupal-project directory. | /var/data/drupal |
| drupal_web_root | Name directory where placed index.php file indside drupal project directory | web |
| drupal_public_files_dir | Absolute path to your drupal files directory | /var/data/drupal_files |
| drupal_hash_salt | Hash salt for drupal site. | demo_site |
| drupal_config_sync_folder | Relative path from drupal_web_root for you config sync directory | sites/default/sync |
| port | Port where you up your drupal site by http protocol. No need if advanced_networking is true | 80 |
| ssl_port | Port where you up your drupal site by https protocol you shoud set ssl_enabled to true | 443 |
| ssl_enabled | Enable https protocol for your project | true |
| ssl_cert_path | Absolute path to fullchain ssl certeficate | /var/data/ssl/fullchain.pem |
| ssl_key_path | Absolute path to ssl private key | /var/data/ssl/privkey.pem |
| phpversion | Name of php-apache drupal contфiner. `develop` in version name means that container have installed xdebug. You can see all version on [docker.hub](https://hub.docker.com/r/jetdevteam/drupal-php-apache/tags?page=1&ordering=last_updated) | 7.4-production |
| xdebug_enviroment | Parameters for xdebug | remote_enable=1 remote_port=9000 remote_host=192.168.105.1 remote_autostart=1 idekey=VSCODE |
| advanced_networking | Set docker network ip to static and add bind to domain name in your /etc/hosts file | false |
| network_id | Network id. its part of of static docker ip 192.168.{network_id}.10 | 105 |
| domain_name | Drupal site domain name | drupal.devel |
| drush_install | Flag for install drush launcher | true |
| drush_version | Drush launcher verions. For drush launcher > 9 you shoud have drush installed in you project | 10 |
| solr | Flag for setup solr docker container and bind it to settings.php | true |
| solr_version | Version of solr. Should be int | 7 |
| solr_configs_path | Absolute path to your solr config directory | /var/data/drupal/solr_config |
| solr_core_name | Name for solr core | drupal |
| memcache | Flag for setup memcache docker container and bind it to settings.php | false |
| db_dump_path | Absolute path to drupal sql database dump. Import by db.yml playbook | /var/data/db/db.sql |
| database | Type of database. Availible database: mysql, mariadb | mysql |
| mysql_root_password | mysql password for root user | root |
| mysql_user | mysql user name | docker |
| mysql_password | mysql password | docker |
| mysql_database | mysql databse name for drupal | drupal |
| import_database | import database immediately after up docker containers by up.yml playbook. Ensure you have right path to sql dump | false |
| install_adminer |  Flag for setup adminer | false |
| adminer_port | http port for admniner | 8080 |
| run_drush_commands | run drush_commands immediately after up docker containers by up.yml playbook. | false |
| drush_commands | Drush commands that run by run-drush-commands.yml playbook | ['cr', 'cc', 'si'] |
| custom_drupal_settings | custom drupal settings. Inserting to end settings.php file | $settings['trusted_host_patterns'] = ['drupal.devel']; |
