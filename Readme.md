
# Tips
* All volumes can be removed by running: ```docker-compose down -v```
* External volumes can be created against mount points like this: ```docker volume create --opt type=none --opt device=/path/to/shows --opt o=bind --name series```
* The default username/password for NZBGet is _nzbget_/_tegbzn6789_
* Password authentication for NZBGet can be disabled under **Settings->Security** by clearing out both **ControlUsername** and **ControlPassword** fields


# Intitial setup
* Update **.env** with the hostname of your server and your timezone
* Services can be accessed via http://_servicename_._hostname_/ except for Organizr which can be accessed by http://_hostname_/
* Services can access each other via their servicename, so Sonarr can ping transmission via the hostname _transmission_


# Backup / Restore
Backups can be made by running ```./backup-volumes.sh backup destination/```.  This will create timestamped backup files of each important volume in the destination directory.  To restore, simply run ```./backup-volumes.sh restore destination/```.  This will overwrite any existing volumes that may exist.