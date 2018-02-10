* NZBGet default username: nzbget
* NZBGet default password: tegbzn6789
* PlexPy log path (Settings->Plex Media Server->PLEX LOGS->Logs Folder): /logs/Library/Application\ Support/Plex\ Media\ Server/Logs

all volumes can be removed by running ```docker-compose down -v```

external volumes can be created against mount points like this:
```docker volume create --opt type=none --opt device=/path/to/shows --opt o=bind --name series```