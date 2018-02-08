#!/bin/bash

usage() {
    echo "Usage: backup-volumes <backup|restore> <backup_directory>"
    exit 64
}

if [ $# -ne 2 ]; then
    usage
fi

MODE=$1
BACKUP_DIR=$2

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory does not exist: $BACKUP_DIR"
    exit 1
fi

BACKUP_DIR_ABS=$( cd "$BACKUP_DIR" && pwd )

DOCKER_COMPOSE_PROJECT=$(basename $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))
# echo "MODE:" $MODE
# echo "DOCKER_COMPOSE_PROJECT:" $DOCKER_COMPOSE_PROJECT
# echo "BACKUP_DIR:" $BACKUP_DIR
# echo "BACKUP_DIR_ABS:" $BACKUP_DIR_ABS

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
            DEST="${volume}.${TIMESTAMP}"
            echo "Backing up" $volume "->" "${BACKUP_DIR_ABS}/${DEST}.tar.bz2"
            docker run --rm -v $volume:/volume:ro -v $BACKUP_DIR_ABS:/backup loomchild/volume-backup backup "$DEST"
        done
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