BACKUPDIR="/var/backups/postgres"
DATE=`/bin/date +%F-%R`

su - postgres -c "/usr/bin/pg_dumpall -U postgres  | gzip -c - > $BACKUPDIR/postgres-all_$DATE.sql.gz"

su - postgres -c "/usr/bin/pg_dumpall -g -U postgres | gzip -c - > $BACKUPDIR/postgres-globals_$DATE.sql.gz"

/usr/bin/find "$BACKUPDIR" -type f -mtime +7 -exec rm -f '{}' \;

