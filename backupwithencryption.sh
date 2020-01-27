#!/bin/bash

################################################################

##   MySQL Database Backup Script 
##   Written By: nithin


################################################################

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +"%d%b%Y"`
  

################## Update below values  ########################

DB_BACKUP_PATH='/backup/dbbackup'
MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USER='username'
DATABASE_NAMES='testdb1,testdb2,testdb3'
BACKUP_RETAIN_DAYS=30   ## Number of days to keep local backup copy

#################################################################

mkdir -p ${DB_BACKUP_PATH}/${TODAY}

for DB in $(echo ${DATABASE_NAMES} | sed "s/,/ /g")

do

  echo "Backup started for database - ${DB}"


  mysqldump -h ${MYSQL_HOST} \
     -P ${MYSQL_PORT} \
     -u ${MYSQL_USER} \
     ${DB} | gzip -c | openssl smime -encrypt -binary -text -aes256 -out ${DB_BACKUP_PATH}/${TODAY}/${DB}-${TODAY}.enc -outform DER /root/mysqlenckey/mysqldump-key.pub.pem

  if [ $? -eq 0 ]; then
    echo "Database backup successfully completed"
  else
    echo "Error found during backup"
    exit 1
  fi
  ##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####

 DBDELDATE=`date +"%d%b%Y" --date="${BACKUP_RETAIN_DAYS} days ago"`

 if [ ! -z ${DB_BACKUP_PATH} ]; then
      cd ${DB_BACKUP_PATH}
      if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
            rm -rf ${DBDELDATE}
      fi
 fi

done
