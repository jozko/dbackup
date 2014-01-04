#!/bin/bash

BACKUPDIR="/var/backups/mysql"
DATE=`/bin/date +%F-%R`

/usr/bin/mysqldump -u root -proot --all-databases | gzip -c - > $BACKUPDIR/mysql-all_$DATE.sql.gz

/usr/bin/find "$BACKUPDIR" -type f -mtime +7 -exec rm -f '{}' \;

