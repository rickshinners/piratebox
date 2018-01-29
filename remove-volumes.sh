#!/bin/bash

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCKER_COMPOSE_PROJECT="$(basename $CWD)"
DOCKER_COMPOSE="docker-compose -f ${CWD}/docker-compose.yaml --project-directory ${CWD}"

$DOCKER_COMPOSE down

VOLUMES=$(docker volume ls --filter "label=com.docker.compose.project=${DOCKER_COMPOSE_PROJECT}" --quiet)
if [ ! -z "$VOLUMES" ]; then
    docker volume rm $VOLUMES
fi