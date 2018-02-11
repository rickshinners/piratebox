
# Tips
* all volumes can be removed by running: ```docker-compose down -v```

* external volumes can be created against mount points like this: ```docker volume create --opt type=none --opt device=/path/to/shows --opt o=bind --name series```


# Intitial setup
When the docker volumes are created you'll need to do some initial setup to ensure the nginx reverse proxy works with each subsystem and that they can talk to each other.
## Sonarr
Sonarr must be accessed by http://<hostname>:8989/ until after the initial setup.

Set the following settings:
* **General->URL Base**: _/sonarr_

Add the following download clients:
* NZBGet
    * **Host**: _nzbget_
    * **Username**: (if set)
    * **Password**: (if set)
* Transmission
    * **Host**: _transmission_
    * **Url Base**: _/transmission_
## Radarr
Radarr must be accessed by http://<hostname>:7878/ until after the initial setup.

Set the following settings:
* **General->URL Base**: _/radarr

Add the following download clients:
* NZBGet
    * **Host**: _nzbget_
    * **Username**: (if set)
    * **Password**: (if set)
* Transmission
    * **Host**: _transmission_
    * **Url Base**: _/transmission_
## Plex
_Note: Host networking does not work on Mac OSX_

Plex can be accessed via http://<hostname>:32400/
## Plexpy
Set the following settings:
* **Plex Media Server->PLEX LOGS->Logs Folder**: _/logs/Library/Application Support/Plex Media Server/Logs_
## Transmission
No setup needed
## NzbGet
* Default username: _nzbget_
* Default password: _tegbzn6789_
* Password authentication can be disabled under **Settings->Security** by clearing out both **ControlUsername** and **ControlPassword** fields
