#!/bin/bash

usage() {
    echo "Usage: backup-volumes <backup|restore> <docker-compose-project>"
    exit 64
}

if [ $# -ne 2 ]; then
    usage
fi

MODE=$1
DOCKER_COMPOSE_PROJECT=$2
echo "MODE:" $MODE
echo "DOCKER_COMPOSE_PROJECT:" $DOCKER_COMPOSE_PROJECT

BACKUP_DIR="/backup"
mkdir -p "$BACKUP_DIR"

RUNNING_CONTAINERS=$(docker ps --filter "label=com.docker.compose.project=${DOCKER_COMPOSE_PROJECT}" -q)
VOLUMES=$(docker volume ls --filter "label=com.docker.compose.project=${DOCKER_COMPOSE_PROJECT}" --filter "label=com.github.rickshinners.piratebox.backup=yes" --quiet)

stop_containers() {
    if [ ! -z "$RUNNING_CONTAINERS" ]; then
        echo "Stopping running containers in ${DOCKER_COMPOSE_PROJECT}..."
        docker stop $RUNNING_CONTAINERS | xargs -I {} docker inspect --format="{{.Name}}" {}
    fi
}

start_containers() {
    if [ ! -z "$RUNNING_CONTAINERS" ]; then
        echo "Starting previously running containers..."
        docker start $RUNNING_CONTAINERS | xargs -I {} docker inspect --format="{{.Name}}" {}
    fi
}

backup() {
    stop_containers
    TIMESTAMP=$(date +%Y%m%dT%H%M%S)
    if [ ! -z "$VOLUMES" ]; then
        for volume in $VOLUMES; do
            DEST="${volume}_${TIMESTAMP}"
            echo "Backing up" $volume "->" "${BACKUP_DIR}/${DEST}.tar.bz2"
            docker run --rm -v $volume:/volume:ro -v $BACKUP_DIR:/backup loomchild/volume-backup backup "$DEST"
            #ln -s "${BACKUP_DIR}/${DEST}.tar.bz2" "${BACKUP_DIR}/${volume}.latest.tar.bz2"
        done
        ls -al $BACKUP_DIR
    else
        echo "No volumes found to backup"
    fi
    start_containers
}

case "$MODE" in
    "backup")
        backup
        ;;
    "restore")
        restore
        ;;
    *)
        usage
        ;;
esac

exit 0

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BACKUP_DIR="/backup"
mkdir -p "$BACKUP_DIR"

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