#!/bin/bash

. ./common.sh

BACKUP_DIR="./backups"
mkdir -p "$BACKUP_DIR"
BACKUP_DIR_ABS="$( cd "$BACKUP_DIR" && pwd )"

RUNNING_CONTAINERS=$(docker ps --filter "label=com.docker.compose.project=${DOCKER_COMPOSE_PROJECT}" -q)

if [ ! -z "$RUNNING_CONTAINERS" ]; then
    echo "Stopping running containers in ${DOCKER_COMPOSE_PROJECT}..."
    docker stop $RUNNING_CONTAINERS
fi

VOLUMES_TO_BACKUP=$(docker volume ls --filter "label=com.docker.compose.project=${DOCKER_COMPOSE_PROJECT}" --filter "label=com.github.rickshinners.piratebox.backup=yes" --quiet)
TIMESTAMP=$(date +%Y%m%dT%H%M%S)
if [ ! -z "$VOLUMES_TO_BACKUP" ]; then
    for volume in $VOLUMES_TO_BACKUP; do
        DEST="${volume}_${TIMESTAMP}"
        echo "Backing up" $volume "->" "${BACKUP_DIR_ABS}/${DEST}.tar.bz2"
        docker run --rm -v $volume:/volume -v $BACKUP_DIR_ABS:/backup loomchild/volume-backup backup "$DEST"
        ln -s "${BACKUP_DIR_ABS}/${DEST}.tar.bz2" "${BACKUP_DIR_ABS}/${volume}.latest.tar.bz2"
    done
else
    echo "No volumes found to backup"
fi

if [ ! -z "$RUNNING_CONTAINERS" ]; then
    echo "Starting previously running containers..."
    docker start $RUNNING_CONTAINERS
fi