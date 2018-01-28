#!/bin/bash

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PREFIX="$(basename $CWD)"
DOCKER_COMPOSE="docker-compose -f ${CWD}/docker-compose.yaml --project-directory ${CWD}"

$DOCKER_COMPOSE down

VOLUMES=$(${DOCKER_COMPOSE} config --volumes | sed -e '/series/d' -e '/movies/d' | sed "s/^/${PREFIX}_/" | tr '\n' ' ')
docker volume rm $VOLUMES