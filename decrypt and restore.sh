#!/bin/bash
  
################################################################

##   MySQL Database Backup Script 
##   Written By: nithin


################################################################

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +"%d%b%Y"`

echo -n "Enter Decrypting Directory name and press [ENTER]: "
read Decrypting_DIR

################## Update below values  ########################
DB_BACKUP_PATH=/backup/dbbackup

#################################################################

mkdir -p ${DB_BACKUP_PATH}/Decrypted_DIR

for DB in `ls /backup/dbbackup/${Decrypting_DIR}/`

do
  echo "Decrypting started for database - ${DB}"
  cd /backup/dbbackup/${Decrypting_DIR}/
  New_Filename=`echo ${DB} | cut -d. -f1`
  openssl smime -decrypt -binary -in ${DB} -inform DEM -inkey /root/mysqlenckey/mysqldump-key.priv.pem -out ${DB_BACKUP_PATH}/Decrypted_DIR/${New_Filename}.sql.gz

  if [ $? -eq 0 ]; then
    echo "Decrypt backup successfully completed"
  else
    echo "Error found during backup"
    exit 1
  fi

done
echo "Please find the decrypted files in the directory "
