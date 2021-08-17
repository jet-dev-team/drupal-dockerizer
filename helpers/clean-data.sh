#!/bin/bash

set -o allexport
source ./$1
set +o allexport

export USER_UID=`id -u`
export USER_GID=`id -g`

docker-compose down

rm -rf ./data/logs/apache2/*
