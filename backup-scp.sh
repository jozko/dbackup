#!/bin/bash

HELP="Use arguments:\n
backup for normal backup procedure (will do full on first run, incremental after that)\n
full to force full backup\n
rotate-view to view old sets\n
rotate to actually delete old sets\n
status to view current backup sets status\n 
test to test settings (will do dry run, not changing anything)\n
restore to restore file(s) or directorie(s)\n"

# Source nastavitev
source /opt/duplicity-scripts/backup-settings.conf
# Export gesla za šifriranje backupa
export PASSPHRASE

# Funkcija ki preverja izhodne statuse ukazov
# Postane glasna, ko gre kaj narobe

function checkexit {

    if [ $? != "0" ]; then
        echo "Nonzero exit status detected while running $0 !"
    fi  

}

# Pre-backup funkcija kliče skripte, 
# ki izvajajo ostale z backupom povezane taske
# Npr - dump baze
# Po vsakem klicu zunanje skripte dodaš checkexit

function prebackup {
    /opt/duplicity-scripts/plugins/mysql-duplicity.sh
    checkexit
    /opt/duplicity-scripts/plugins/pg-duplicity.sh
    checkexit
}

case $1 in
"backup")
prebackup
duplicity \
   --ssh-options="-oIdentityFile=$IDFILE" \
   --scp-command="scp -l 3072" \
   --volsize $VOLSIZE  \
   --include-globbing-filelist "$FILELIST" \
   / $TARGET
   echo $?
;;

"full")
prebackup    
duplicity full \
   --ssh-options="-oIdentityFile=$IDFILE" \
   --scp-command="scp -l 3072" \
   --volsize $VOLSIZE \
   --include-globbing-filelist "$FILELIST" \
   / $TARGET
;;

"test")
duplicity \
   --ssh-options="-oIdentityFile=$IDFILE" \
   --scp-command="scp -l 3072" \
   --volsize $VOLSIZE  \
   --dry-run \
   --include-globbing-filelist "$FILELIST" \
   / $TARGET
   ;;

"rotate-view") 
duplicity remove-all-but-n-full $FULLBACKUPS \
   --ssh-options="-oIdentityFile=$IDFILE" \
   --scp-command="scp -l 3072" \
   $TARGET
;;

"rotate") 
duplicity remove-all-but-n-full $FULLBACKUPS \
    --ssh-options="-oIdentityFile=$IDFILE" \
    --scp-command="scp -l 3072" \
    --force \
   $TARGET
;;

"status")
duplicity collection-status \
    --ssh-options="-oIdentityFile=$IDFILE" \
    --scp-command="scp -l 3072" \
    $TARGET
;;

"show-files")
duplicity list-current-files \
    --ssh-options="-oIdentityFile=$IDFILE" \
    --scp-command="scp -l 3072" \
    $TARGET
;;

"restore")

    if  [ -z $2 ] || [ -z $3 ]; then 
        echo "Need to specify WHAT to restore nad WHERE to restore, example:"
        echo "$0 restore home/my/precious/mp3 /tmp/mp3"
        exit 0 
    fi
    
    duplicity --ssh-options="-oIdentityFile=$IDFILE" --scp-command="scp -l 3072"  --file-to-restore $2 $TARGET $3

;;

"help")
echo -e $HELP
;;

*)
echo "Use help for usage tips"
;;
esac
