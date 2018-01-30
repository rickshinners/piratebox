CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCKER_COMPOSE_PROJECT="$(basename $CWD)"
DOCKER_COMPOSE="docker-compose -f ${CWD}/docker-compose.yaml --project-directory ${CWD}"