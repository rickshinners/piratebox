FROM alpine

RUN apk update && \
    apk add docker

COPY backup-volumes.sh /

VOLUME /var/run/docker.sock
VOLUME /backup

ENTRYPOINT [ "/bin/sh", "/backup-volumes.sh" ]