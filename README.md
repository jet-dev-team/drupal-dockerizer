# Drupal Docker Compose collection

## Prepare your system

Add to your user docker group

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

Relogin to your account for aplly changes.

Let’s install docker and docker-compose.

```bash
sudo apt update && sudo apt -y install docker.io
```

Install latest `docker-compose`. Ubuntu repository has a little bit outdated version.
Read more here: <https://docs.docker.com/compose/install/>.

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## Quick start

To quickly up drupal recomended project run:

`sh examples/scripts-automation/quick-start.bash`

After go to <http://localhost> and you should see installed Drupal
