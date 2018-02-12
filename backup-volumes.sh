#!/usr/bin/env bash

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
            DEST="${volume}.${TIMESTAMP}.tar.gz"
            echo "Backing up" $volume "->" "${BACKUP_DIR_ABS}/${DEST}"
            docker run --rm -v $volume:/volume:ro -v "${BACKUP_DIR_ABS}":/backup alpine:latest tar -czf "/backup/${DEST}" -C "/volume/" ./
        done
    else
        echo "No volumes found to backup"
    fi
    start_containers
}

in_array() {
    local haystack=${1}[@]
    local needle=${2}
    for i in ${!haystack}; do
        if [[ ${i} == ${needle} ]]; then
            return 0
        fi
    done
    return 1
}

restore() {
    stop_containers
    # Create list of volume names to restore from the backup directory
    declare -a volumes_to_restore
    for filename in $(ls "$BACKUP_DIR_ABS"); do
        # Parameter substitution: https://www.tldp.org/LDP/abs/html/parameter-substitution.html
        volume_name="${filename%%.*}"
        docker_compose_project="${volume_name%%_*}"
        if [ "$docker_compose_project" == "$DOCKER_COMPOSE_PROJECT" ]; then
            in_array volumes_to_restore $volume_name || volumes_to_restore+=("$volume_name")
        fi
    done
    # Restore each volume
    for volume_name in ${volumes_to_restore[@]}; do
        most_recent=$(ls "${BACKUP_DIR_ABS}/${volume_name}."* | tail -n 1)
        echo "Restoring $volume_name from ${most_recent}"

        docker_compose_volume="${volume_name#*_}"
        # Ensure volume exists
        docker volume create --name="$volume_name" \
            --label com.docker.compose.project="${DOCKER_COMPOSE_PROJECT}" \
            --label com.docker.compose.volume="${docker_compose_volume}" \
            --label com.github.rickshinners.piratebox.backup="yes" > /dev/null
        # Do the restore
        filename=$(basename "${most_recent}")
        docker run --rm -v $volume_name:/volume alpine:latest rm -rf /volume/* /volume/..?* /volume/.[!.]*
        docker run --rm -v $volume_name:/volume -v "${BACKUP_DIR_ABS}":/backup alpine:latest tar -C /volume -xzf "/backup/${filename}"
    done
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