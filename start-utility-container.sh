#!/bin/bash

DOCKER_COMPOSE_PROJECT=$(basename $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))
VOLUMES=$(docker volume ls --filter "label=com.docker.compose.project=${DOCKER_COMPOSE_PROJECT}" --quiet)

if [ ! -z "$VOLUMES" ]; then
    VOLUME_ARGS="-v movies:/volumes/movies -v series:/volumes/series"
    for volume in $VOLUMES; do
        COMPOSE_VOLUME_NAME=$(docker volume inspect --format '{{ index .Labels "com.docker.compose.volume" }}' $volume)
        VOLUME_ARGS="$VOLUME_ARGS -v $volume:/volumes/$COMPOSE_VOLUME_NAME"
    done
    # echo $VOLUME_ARGS
else
    echo "No volumes found for this docker-compose project"
fi

docker run $VOLUME_ARGS --rm -it rickshinners/utility-container