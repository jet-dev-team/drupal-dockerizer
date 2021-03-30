# Drupal Dockerizer

## Requirements

- python [instruction](https://www.python.org/downloads/)
- git [instruction for install](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- ansible [instruction for install](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- docker [instruction for install](https://docs.docker.com/get-docker/)
- docker-compose [instruction for install](https://docs.docker.com/compose/install/)

## Quickstart

You can use ansible-pull tool from standard package ansible for quick setup your project.

For that create config yml file in any place your need(in drupal project directory or external folder). Ensure that all needed config options is setup.

Minimum required options:
```yaml
---

compose_project_name: drupal-project
docker_runtime_dir: drupal-project
user_uid: 1000
user_gid: 1000
drupal_root_dir: /var/data/drupal
drupal_web_root: web
drupal_files_dir: /var/data/drupal/web/sites/default/files
```
Remember: other options will setted by default from `default.config.yml` file.

For more options [see](CONFIG.md)

For up your drupal project in docker containers run:

```
ansible-pull --extra-vars @/<absolute_pat_to_config> -U https://github.com/jet-dev-team/drupal-dockerizer.git main.yml --ask-become-pass
```

After done you should have drupal project in docker containers with empty database.
Check containers status by run `docker ps` command.
If you use database dump you can set in config  option `db_dump_path` to absolute path to you database dump. For import database run:
```
ansible-pull --extra-vars @/<absolute_pat_to_config> -U https://github.com/jet-dev-team/drupal-dockerizer.git db.yml
```

For stop or up containers just replace `db.yml` in command to `stop.yml` or `up.yml`

For fully remove all projects data you can run:
```
ansible-pull --extra-vars @/<absolute_pat_to_config> -U https://github.com/jet-dev-team/drupal-dockerizer.git reset.yml --ask-become-pass
```
This command remove all projects containers, volumes with data in database and runtime directory.

### Usage ansible-pull

By default pulling data by ansible-pull placed in `~/.ansible/pull/<hostname>` directory. You can change it by add to ansible-pull command destination option `-d <DEST>` or `--directory <DEST>`.

You can anchor version drupal-dockerizer by add to ansible-pull command option `-C <TAG_NAME>` or `--checkout <TAG_NAME>`

For more information about ansible-pull see [documentations](https://docs.ansible.com/ansible/latest/cli/ansible-pull.html).

### Xdebug setup

For advanced network setup set in `config.yml` variable `xdebug_enviroment` like this

```bash
remote_enable=1 remote_connect_back=1 remote_port=9008 remote_host=192.168.{network_id}.1 show_error_trace=0 show_local_vars=1 remote_autostart=1 show_exception_trace=0 idekey=VSCODE
```

For work Xdebug with advanced networking in vscode add to your launcher.json file in project next lines:

```json
    {
      "name": "XDebug Docker",
      "type": "php",
      "request": "launch",
      "hostname" : "192.168.{network_id}.1",
      "port": 9008,
      "pathMappings": {
        "/var/www": "${workspaceRoot}/<path_to_drupal_project>"
      },
      "xdebugSettings": {
        "show_hidden": 1,
        "max_data": -1,
        "max_depth": 2,
        "max_children": 100,
      }
    },
```

#### For MacOs the next config should be used

Make sure your `config.yml` contains the next config:

```bash
# Enviroment variable for php xdebug extensions
xdebug_enviroment: remote_enable=1 remote_connect_back=0 remote_port=9000 remote_host=10.254.254.254 show_error_trace=0 show_local_vars=1 remote_autostart=1 show_exception_trace=0 idekey=VSCODE
```

Make sure you've created Host address alias on MacOS:

```bash
sudo ifconfig lo0 alias 10.254.254.254
```

Your `launch.json` should look like the next config:

```json
    {
      "name": "XDebug Docker",
      "type": "php",
      "request": "launch",
      "port": 9000,
      "pathMappings": {
        "/var/www": "${workspaceRoot}/<path_to_drupal_project>"
      },
      "xdebugSettings": {
        "show_hidden": 1,
        "max_data": -1,
        "max_depth": 2,
        "max_children": 100,
      }

```

How to use debugger with Drush commands?

1. Get the name of web server container using command: `docker ps | grep webserver`
2. SSH into the container by name. Example: `docker exec -it yourproject-php72-develop bash`
3. Set your breakpoint and run Drush command as usual

### Advanced Networking

You can use an advanced docker network to be able to conveniently host multiple Drupal projects on one computer.

Set in config.yml `advanced_networking: true`.

You can change the ip address of the project using the variable `network_id` in `config.yml` file

You can change doamin name by variable `domain_name` in `config.yml` file

#### Advanced Networking Limitation

The advanced network only works on a machine with a Linux distribution.

#### Advanced Networking project structure

- `Adminer` placed on domain name and on 8080 port.
- Solr 4 placed on domain name and on 8983 port and /solr path. `http://drupal.devel:8983/solr` for examle.
- Data Base placed on 192.168.<<network_id>>.13 and on 3306 port. You can connect to DB by vscode [extension](https://marketplace.visualstudio.com/items?itemName=formulahendry.vscode-mysql) or from `Adminer`

### Drush usage

Run in terminal: `docker exec my-project-php74 drush <drush-command>` for run drush command.
If you change compose project name or php version in config replace `my-project-php74` to `<compose_project_name>-<phpversion>`.

Use the next command in order to ran multiple Drush commands.

```bash
sudo ansible-playbook -vvv run-drush-commands.yml --connection=local
````

Change `drush_commands` variable in your `config.yml` file like this:

```yaml
drush_commands:
  - 'updb'
  - '-v sapi-r'
  - '-v sapi-i'
  - ...
```
## Development drupal-dockerizer

### Prepare project structure

- `db`: create this directory and download database dump here if exists.
- `code`: clone your project files into this directory.
- `drupal-dockerizer`: clone drupal-dockerizer project in this directory.
- `files`: create the directory and pull Drupal assets here

### Prepare your config for Drupal Dockerizer

```bash
cd drupal-dockerizer
cp default.config.yml config.yml
```
### Start local environment

```bash
cd drupal-dockerizer
ansible-playbook main.yml --ask-become-pass
ansible-playbook run-drush-commands.yml
```

### Import database from dump

```bash
cd drupal-dockerizer
ansible-playbook db.yml
```

## FAQ

### How to reset everything and start from scratch?

```bash
cd drupal-dockerizer
ansible-playbook reset.yml --ask-become-pass
```

### How to clear Docker cache?

```bash
docker system prune -a -f
```

### How to enhance MacOS performance?

- make sure your `config.yml` contains `docker_cached_volume: true`
- make sure you add more resources to Docker via Preferences -> Recources
- make sure you set `debug` to `false` in Docker Engine preferences
