# Drupal Dockerizer

A set of Ansible playbooks for spinning up Drupal projects with Docker Compose.

Drupal Dockerizer is suitable for spinning up:

- Local development environments (with XDebug support)
- Automated CI builds
- Staging and testing servers

YAY! :boom: You can spin up multiple environments on a single machine!

Drupal Dockerizer works best on Linux (deb-based distributions have been tested).

To spin up a development environment with Drupal Dockerizer on MacOS and Windows you could use virtual machines or remote servers with Linux installed. Take a look at [Visual Studio Code Remote development](https://code.visualstudio.com/docs/remote/remote-overview).

In a nutshell Drupal Dockerizer is not more than an Ansible script which automates routine tasks for getting valid `docker-compose.yml` files.

## How to install Drupal 9 on fresh Ubuntu 20.04 with Drupal Dockerizer

We just got a fresh Ubuntu 20.04 server. Let's go through a quick tour about creating new Drupal 9 site installation.

### Prepare your system

Let’s create a local user in order to avoid work under a `root` account.

```bash
groupadd docker

export USERNAME=<username>
useradd -m -G sudo,docker -s /bin/bash $USERNAME
passwd $USERNAME
mkdir /home/$USERNAME/.ssh
curl https://github.com/$USERNAME.keys | tee -a /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME/
```

Let’s install requirements.

```bash
apt update
apt -y install ansible docker.io docker-compose composer git unzip

systemctl enable --now docker.service
```

Now you are able to connect to your server with your SSH keys or just use `su $USERNAME` to log into your user account to start configuring Drupal Dockerizer.

### Configure Drupal Dockerizer

```bash
mkdir ~/Projects
composer create-project drupal/recommended-project ~/Projects/drupal9 --ignore-platform-reqs --no-interaction
git clone https://github.com/jet-dev-team/drupal-dockerizer.git ~/Projects/drupal9/drupal-dockerizer

cat <<EOT > ~/Projects/drupal9/drupal-dockerizer.yml
---

compose_project_name: drupal9
user_uid: `id -u`
user_gid: `id -g`
drupal_root_dir: $HOME/Projects/drupal9
port: 8090
EOT

cd ~/Projects/drupal9/drupal-dockerizer
ansible-playbook main.yml --ask-become-pass
ansible-playbook drush-commands.yml
```

As a result you should receive the next directory structure:

```bash
.
├── composer.json
├── composer.lock
├── drupal-dockerizer
│   ├── CONFIG.md
│   ├── LICENSE
│   ├── README.md
│   ├── ansible.cfg
│   ├── db.yml
│   ├── default.config.yml
│   ├── drupal9
│   ├── drush-commands.yml
│   ├── inventory
│   ├── main.yml
│   ├── requirements.yml
│   ├── reset.yml
│   ├── stop.yml
│   ├── tasks
│   ├── templates
│   └── up.yml
├── drupal-dockerizer.yml
├── vendor
│   └── ...
└── web
    ├── index.php
    └── ...
```

You are done. You can access your fresh Drupal 9 site by visiting your IP address on port 8090.

### How does it work internally?

There is no magic! It is just a `docker-compose.yml` file. You can find it inside the `drupal-dockerizer` directory.

```bash
.
├── drupal-dockerizer
│   ├── drupal9
│   │   └── docker-compose.yml ←
│   └── ...
├── drupal-dockerizer.yml
├── vendor
│   └── ...
└── web
    ├── index.php
    └── ...
```

```bash
cat ~/Projects/drupal9/drupal-dockerizer/drupal9/docker-compose.yml
```

Now you can use standard Docker Compose to manage your installation.

All the configuration is done via `drupal-dockerizer.yml` config file. You can find a lot of examples by exploring tests. Take a look at [.github/workflows](.github/workflows).

### Playbooks for controlling your projects

Drupal Dockerizer is shipped with additional Ansible playbooks to help you automate your routine tasks. Make sure you are running those playbooks inside the `drupal-dockerizer` directory. The place where playbook files actually live.

Each new project should start with running `main.yml` playbook which prepares configuration.

### Stop containers

To stop your containers and save the data you can use the `stop.yml` playbook. It's an equivalent of `docker-compose stop` command.

```bash
ansible-playbook stop.yml
```

### Up containers

To spin up your containers you can use the `up.yml` playbook. It's an equivalent of `docker-compose up` command.

```bash
ansible-playbook up.yml
```

### Remove containers and their data

To remove everything and start from scratch you can use `reset.yml` playbook. It's an equivalent of `docker-compose down` command. This command will not remove your code. Please, note this command requires `sudoers` permissions.

```bash
ansible-playbook reset.yml --ask-become-pass
```

After resetting your environment you have to run `main.yml` playbook again to spin up your environment.

### How to run commands inside containers

Plese, run `docker ps` to see your Docker container names.

```bash
docker exec drupal9-7.4-develop drush status
```

### How to access log files

Apache2 and MySQL log files are exposed as volumes, so you can access them by
reading the files on your host machine.

```bash
cat drupal9/logs/apache2/error.log
```

### Import MySQL database from dump

There is a playbook which automates database import into database container.
By default it just picks up the `dump.sql` file from the Drupal root directory.

```bash
.
├── drupal-dockerizer.yml
├── dump.sql ←
└── ...
```

```bash
ansible-playbook db.yml
```

If your database dump was placed somewhere in another directory you can change configuration by adding the line to `drupal-dockerizer.yml` file.

```yml
db_dump_path: /path/to/your/dump.sql
```

### Automate this with Drush commands

There is `drush-commands.yml` playbook which will execute all the Drush commands which are described in `drupal-dockerizer.yml` file. Each new command should go to the new line.

```yml
drush_commands:
  - cr
  - status
```

## Credits

Drupal Dockerizer was created and is maintained with :heart: by Drupal Dockerizer team and [Jet.Dev](https://jet.dev/).
