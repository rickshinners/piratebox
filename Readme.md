
# Tips
* All volumes can be removed by running: ```docker-compose down -v```
* External volumes can be created against mount points like this: ```docker volume create --opt type=none --opt device=/path/to/shows --opt o=bind --name series```
* The default username/password for NZBGet is _nzbget_/_tegbzn6789_
* Password authentication for NZBGet can be disabled under **Settings->Security** by clearing out both **ControlUsername** and **ControlPassword** fields


# Intitial setup
* Copy **.env.example** to **.env** and fill in each value.  The AWS variables are for the ACME DNS challenge and require the ability to create TXT DNS records in your hosted zone.
* Update your e-mail address in **traefik/traefik.toml**
* Create **traefik/acme.json** with the proper permissions with the following commands:
    ```
    touch traefik/acme.json
    chmod 600 traefik/acme.json
    ```
* Create your **.htpasswd** file with the following command:
    ```
    htpasswd -cBC 12 traefik/.htpasswd <username>
    ```
    * the 12 is the bcrypt cost. You can lower it if the password hash takes too long, or raise it to be more secure
    * Add more users by running the following command for each user:
        ```
        htpasswd -BC 12 traefik/.htpasswd <username>
        ```
* Update the hostname that will be displayed in NetData in **netdata/netdata.conf**.  This is desired since by default this is set to the hostname of the container which is almost never useful.
* Services can be accessed via http://_servicename_._hostname_/ except for Organizr which can be accessed by http://_hostname_/
* Services can access each other via their servicename, so Sonarr can ping transmission via the hostname _transmission_


# Backup / Restore
Backups can be made by running ```./backup-volumes.sh backup destination/```.  This will create timestamped backup files of each important volume in the destination directory.  To restore, simply run ```./backup-volumes.sh restore destination/```.  This will overwrite any existing volumes that may exist.