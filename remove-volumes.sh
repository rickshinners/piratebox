#!/bin/bash

. ./common.sh

$DOCKER_COMPOSE down

VOLUMES=$(docker volume ls --filter "label=com.docker.compose.project=${DOCKER_COMPOSE_PROJECT}" --quiet)
if [ ! -z "$VOLUMES" ]; then
    docker volume rm $VOLUMES
fi