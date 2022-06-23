#!/bin/bash

###########################
####### CONFIG DATA #######
###########################

#BACKUP_USER=${$BACKUP_USER:+''}
#HOSTNAME=${HOSTNAME:+pgbouncer}
#USERNAME=${USERNAME:+wbuser}
BACKUP_DIR=/opt/backups/

# List of strings to match against in database name, separated by space or comma, for which we only
# wish to keep a backup of the schema, not the data. Any database names which contain any of these
# values will be considered candidates. (e.g. "system_log" will match "dev_system_log_2010-01")
SCHEMA_ONLY_LIST=""

# Will produce a custom-format backup if set to "yes"
ENABLE_CUSTOM_BACKUPS=yes

# Will produce a gzipped plain-format backup if set to "yes"
ENABLE_PLAIN_BACKUPS=yes

# Will produce gzipped sql file containing the cluster globals, like users and passwords, if set to "yes"
ENABLE_GLOBALS_BACKUPS=false

# Number of minutes to keep backups
MIN_TO_KEEP=1440

# Rsync enabled
RSYNC_ENABLED=true


###########################
#### PRE-BACKUP CHECKS ####
###########################

# Make sure we're running as the required backup user
if [ "$BACKUP_USER" != "" -a "$(id -un)" != "$BACKUP_USER" ]; then
	echo "This script must be run as $BACKUP_USER. Exiting." 1>&2
	exit 1;
fi;


###########################
### INITIALISE DEFAULTS ###
###########################

if [ ! $HOSTNAME ]; then
	HOSTNAME="localhost"
fi;

if [ ! $USERNAME ]; then
	USERNAME="postgres"
fi;


###########################
#### START THE BACKUPS ####
###########################


FINAL_BACKUP_DIR=$BACKUP_DIR"$(date +\%Y-\%m-\%d-\%H-\%M-\%S)/"

echo "Making backup directory in $FINAL_BACKUP_DIR"

if ! mkdir -p $FINAL_BACKUP_DIR; then
	echo "Cannot create backup directory in $FINAL_BACKUP_DIR. Go and fix it!" 1>&2
	exit 1;
fi;


#######################
### GLOBALS BACKUPS ###
#######################
global_backup()
{
  local status=0
  echo -e "\n\nPerforming globals backup"
  echo -e "--------------------------------------------\n"

  if [ $ENABLE_GLOBALS_BACKUPS = "yes" ]
  then
          echo "Globals backup"

          set -o pipefail
          if ! pg_dumpall -g -h "$HOSTNAME" -U "$USERNAME" | gzip > $FINAL_BACKUP_DIR"globals".sql.gz.in_progress; then
            status=1
            echo "[!!ERROR!!] Failed to produce globals backup" 1>&2
          else
            mv $FINAL_BACKUP_DIR"globals".sql.gz.in_progress $FINAL_BACKUP_DIR"globals".sql.gz
          fi
          set +o pipefail
  else
    echo "None"
  fi

  return $status
}


###########################
### SCHEMA-ONLY BACKUPS ###
###########################
schema_backup()
{
  local status=0

  for SCHEMA_ONLY_DB in ${SCHEMA_ONLY_LIST//,/ }
  do
    SCHEMA_ONLY_CLAUSE="$SCHEMA_ONLY_CLAUSE or datname ~ '$SCHEMA_ONLY_DB'"
  done

  SCHEMA_ONLY_QUERY="select datname from pg_database where false $SCHEMA_ONLY_CLAUSE order by datname;"

  echo -e "\n\nPerforming schema-only backups"
  echo -e "--------------------------------------------\n"

  SCHEMA_ONLY_DB_LIST=$(psql -h "$HOSTNAME" -U "$USERNAME" -At -c "$SCHEMA_ONLY_QUERY" postgres)

  echo -e "The following databases were matched for schema-only backup:\n${SCHEMA_ONLY_DB_LIST}\n"

  for DATABASE in $SCHEMA_ONLY_DB_LIST
  do
    echo "Schema-only backup of $DATABASE"

    set -o pipefail
    if ! pg_dump -Fp -s -h "$HOSTNAME" -U "$USERNAME" "$DATABASE" | gzip > $FINAL_BACKUP_DIR"$DATABASE"_SCHEMA.sql.gz.in_progress; then
      status=1
      echo "[!!ERROR!!] Failed to backup database schema of $DATABASE" 1>&2
    else
      mv $FINAL_BACKUP_DIR"$DATABASE"_SCHEMA.sql.gz.in_progress $FINAL_BACKUP_DIR"$DATABASE"_SCHEMA.sql.gz
    fi
    set +o pipefail
  done

  return $status
}

###########################
###### FULL BACKUPS #######
###########################
full_backup()
{
  local status=0

  for SCHEMA_ONLY_DB in ${SCHEMA_ONLY_LIST//,/ }
  do
    EXCLUDE_SCHEMA_ONLY_CLAUSE="$EXCLUDE_SCHEMA_ONLY_CLAUSE and datname !~ '$SCHEMA_ONLY_DB'"
  done

  FULL_BACKUP_QUERY="select datname from pg_database where not datistemplate and datallowconn $EXCLUDE_SCHEMA_ONLY_CLAUSE order by datname;"

  echo -e "\n\nPerforming full backups"
  echo -e "--------------------------------------------\n"

  if DBS=$(psql -h "$HOSTNAME" -U "$USERNAME" -At -c "$FULL_BACKUP_QUERY" postgres); then

    for DATABASE in $DBS
    do

      if [[ $DATABASE =~ "rdsadmin" ]]; then
        echo "Skipping database $DATABASE ..."
        continue
      fi

      if [ $ENABLE_PLAIN_BACKUPS = "yes" ]
      then
        echo "Plain backup of $DATABASE"

        set -o pipefail
        if ! pg_dump -Fp -h "$HOSTNAME" -U "$USERNAME" "$DATABASE" | gzip > $FINAL_BACKUP_DIR"$DATABASE".sql.gz.in_progress; then
          status=1
          echo "[!!ERROR!!] Failed to produce plain backup database $DATABASE" 1>&2
        else
          mv $FINAL_BACKUP_DIR"$DATABASE".sql.gz.in_progress $FINAL_BACKUP_DIR"$DATABASE".sql.gz
        fi
        set +o pipefail
      fi

      if [ $ENABLE_CUSTOM_BACKUPS = "yes" ]
      then
        echo "Custom backup of $DATABASE"

        if ! pg_dump -Fc -h "$HOSTNAME" -U "$USERNAME" "$DATABASE" -f $FINAL_BACKUP_DIR"$DATABASE".custom.in_progress; then
          status=1
          echo "[!!ERROR!!] Failed to produce custom backup database $DATABASE" 1>&2
        else
          mv $FINAL_BACKUP_DIR"$DATABASE".custom.in_progress $FINAL_BACKUP_DIR"$DATABASE".custom
        fi
      fi

    done

    echo -e "\nAll database backups complete!"

  else
    status=1
  fi

  return $status
}


clear_redundant()
{
  # Delete redundant backups
  echo "Deleting redundant backups ..."
  find $BACKUP_DIR -maxdepth 1 -mmin +${MIN_TO_KEEP} -name "*" -exec rm -rf '{}' ';'
}

rsync_backup()
{
  if [ "${RSYNC_ENABLED}" ]; then
    echo "rsyncing ..."
    rsync -rltvvv --delete-after /opt/backups rsync://wb@d96c0c41c688.sn.mynetname.net/wbsync
  else
    echo "skipping rsync"
  fi
}


## MAIN

full_backup || {
  rm -rf $FINAL_BACKUP_DIR
  exit 1
}

clear_redundant

rsync_backup


