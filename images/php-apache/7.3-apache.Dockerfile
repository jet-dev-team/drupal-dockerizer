FROM php:7.3-apache

# Surpresses debconf complaints of trying to install apt packages interactively
# https://github.com/moby/moby/issues/4032#issuecomment-192327844

ARG DEBIAN_FRONTEND=noninteractive

# Install useful tools and install important libaries
RUN apt-get -y update && \
  apt-get -y --no-install-recommends --fix-missing install zsh git vim nano wget sudo\
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
  openssl \
  libxml2-dev

# Clear Apt
RUN rm -rf /var/lib/apt/lists/*

# Update pecl
RUN pecl channel-update pecl.php.net

# Install pecl modules
RUN pecl install \
  imagick \
  memcached \
  apcu-5.1.19

# Configure uploadprogress
RUN git clone https://github.com/php/pecl-php-uploadprogress/ /usr/src/php/ext/uploadprogress/ && \
  docker-php-ext-configure uploadprogress

# Enable php modules
RUN docker-php-ext-enable memcached && \
  docker-php-ext-enable imagick && \
  docker-php-ext-enable apcu

# Opcache enviroment
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
  PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
  PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
  PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

# Install php modulues
RUN docker-php-ext-install pdo_mysql && \
  docker-php-ext-install opcache && \
  docker-php-ext-install uploadprogress && \
  docker-php-ext-install pdo_sqlite && \
  docker-php-ext-install soap && \
  docker-php-ext-install mysqli && \
  docker-php-ext-install curl && \
  docker-php-ext-install tokenizer && \
  docker-php-ext-install json && \
  docker-php-ext-install zip && \
  docker-php-ext-install -j$(nproc) intl && \
  docker-php-ext-install mbstring && \
  docker-php-ext-install gettext && \
  docker-php-ext-install exif

# Install Freetype
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
  docker-php-ext-install -j$(nproc) gd

# Enable apache modules
RUN a2enmod rewrite headers
RUN a2enmod ssl

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Cleanup
RUN rm -rf /usr/src/*
