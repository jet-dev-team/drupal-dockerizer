FROM php:8.0-apache

# Surpresses debconf complaints of trying to install apt packages interactively
# https://github.com/moby/moby/issues/4032#issuecomment-192327844

# Upload progress not work in php-8.0 for now.

ARG DEBIAN_FRONTEND=noninteractive

# Install useful tools and install important libaries
RUN apt-get -y update && \
  apt-get -y --no-install-recommends --fix-missing install vim nano wget sudo\
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libmagickwand-dev \
  dialog \
  libsqlite3-dev \
  libsqlite3-0 \
  default-mysql-client \
  zlib1g-dev \
  libzip-dev \
  libicu-dev \
  apt-utils \
  build-essential \
  git \
  curl \
  libmemcached-dev \
  libonig-dev \
  libcurl4 \
  libcurl4-openssl-dev \
  zip \
  unzip \
  openssl \
  libxml2-dev \
  imagemagick

# Clear Apt
RUN rm -rf /var/lib/apt/lists/*

# Opcache enviroment
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
  PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
  PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
  PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

# Update pecl
RUN pecl channel-update pecl.php.net

# Install pecl modules
RUN pecl install \
  memcached \
  apcu

RUN git clone https://github.com/Imagick/imagick/ /usr/src/php/ext/imagick/ && \
  docker-php-ext-configure imagick

# Enable php modules
RUN docker-php-ext-enable memcached && \
  docker-php-ext-enable apcu

# Install php modulues
RUN docker-php-ext-install pdo_mysql && \
  docker-php-ext-install bcmath && \
  docker-php-ext-install opcache && \
  docker-php-ext-install imagick && \
  docker-php-ext-install soap && \
  docker-php-ext-install mysqli && \
  docker-php-ext-install gettext && \
  docker-php-ext-install exif

# Install Freetype
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg && \
  docker-php-ext-install gd

# Enable apache modules
RUN a2enmod rewrite headers
RUN a2enmod ssl

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ARG XDEBUG_INSTALL=false
ARG XDEBUG_VERSION=3.0.4
ARG DOCKER_NETWORK_GATEWAY_IP
RUN if [ "$XDEBUG_INSTALL" = "false" ] ; then\
    echo 'Skip xdebug install';\
  else\
    pecl install xdebug-$XDEBUG_VERSION;\
    docker-php-ext-enable xdebug;\
    xdebug_conf_path=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini;\
    echo "xdebug.client_host=${DOCKER_NETWORK_GATEWAY_IP}" >> $xdebug_conf_path;\
    echo "xdebug.client_port=9000" >> $xdebug_conf_path;\
    echo "xdebug.mode=debug,develop" >> $xdebug_conf_path;\
    echo "xdebug.start_with_request=yes" >> $xdebug_conf_path;\
  fi

ARG NODE_VERSION=14
ARG NODE_INSTALL=false
RUN if [ "$NODE_INSTALL" = "false" ];then\
    echo 'Skip nodejs install';\
  else \
    curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash -;\
    sudo apt-get install -y nodejs;\
  fi

# Set php memory limit
ARG PHP_MEMORY_LIMIT=512M
RUN echo "memory_limit = $PHP_MEMORY_LIMIT" >> /usr/local/etc/php/conf.d/memory_limit.ini

# Enable apcu in cofig
RUN echo "apc.enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

RUN sudo curl -fsSL -o /usr/local/bin/drush "https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar" && \
  sudo chmod +x /usr/local/bin/drush

# Cleanup
RUN rm -rf /usr/src/*

# Create user
ARG USER_UID=0
ARG USER_GID=0
ARG USER_NAME=root
RUN if [ "$USER_UID" = "0" ] || [ "$USER_NAME" = "root" ];then\
    echo 'Skip user create.';\
    echo APACHE_RUN_USER=www-data >> /etc/apache2/envvars;\
    echo APACHE_RUN_GROUP=www-data >> /etc/apache2/envvars;\
  else \
    useradd -ms /bin/bash $USER_NAME;\
    groupmod --gid $USER_GID $USER_NAME;\
    usermod --uid $USER_UID --gid $USER_GID $USER_NAME;\
    chown -R $USER_NAME:$USER_NAME /var/www;\
    echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME;\
    chmod 0440 /etc/sudoers.d/$USER_NAME;\
    echo "export APACHE_RUN_USER=$USER_NAME" >> /etc/apache2/envvars;\
    echo "export APACHE_RUN_GROUP=$USER_NAME" >> /etc/apache2/envvars;\
  fi

RUN chmod +x /usr/local/bin/docker-php-entrypoint

USER $USER_NAME
