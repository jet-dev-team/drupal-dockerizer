# Drupal Dockerizer

## Requirements

- Ubuntu >= 20.04
- Python >= 3.5
- Docker
- Docker Compose
- Ansible >= 2.8
- Git

## Quickstart

### Get the code of this repository to your project directory

Example project structure:

```
<project>/
  - db/
  - code/
  - docker/
  - files/
```

### Prepare your config

```bash
cd <project>/docker
cp default.config.yml config.yml
```

Set your preferred settings.

### Get all the requirements

```bash
cd <project>/docker
ansible-galaxy install -r requirements.yml
```

Do not worry if there is an error about empty requirements.

### Start new local environment

```bash
cd <project>/docker
sudo ansible-playbook -vvv main.yml --connection=local --extra-vars=init_project=true
```

### Start local environment

```bash
cd <project>/docker
sudo ansible-playbook -vvv main.yml --connection=local
```

### Import database from dump

```bash
cd <project>/docker
sudo ansible-playbook -vvv db.yml --connection=local
```

### Development mode

Set in config.yml `develop: true`
For work Xdebug in vscode add to your launcher.json file in project next lines:

```json
    {
      "name": "XDebug Docker",
      "type": "php",
      "request": "launch",
      "hostname" : "192.168.{network_id}.1",
      "port": 9008,
      "pathMappings": {
        "/var/www": "${workspaceRoot}/path_to_project"
      },
      "xdebugSettings": {
        "show_hidden": 1,
        "max_data": -1,
        "max_depth": 2,
        "max_children": 100,
      }
    },
```

#### Development project structure

- Site placed on domain name and on 80 port.
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

## FAQ

### How to reset everything and start from scratch?

```bash
cd <project>/docker
sudo ansible-playbook -vvv reset.yml --connection=local
```
