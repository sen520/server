#! /bin/bash

DB_HOST='localhost:27017' # mongo host
DB_NAME='data' # mongo database

OUT_DIR='/root/alpha/mongod_bak_now' # Temporary catalogue
TAR_DIR='/root/alpha/mongod_bak_list' # Backup storage path

DB_USER='test' # mongo username
DB_PASS='test' # mongo user password

DATE=$(date +'%Y-%m-%d') # Get current system time

OP_DIR="$OUT_DIR/$DATE" # Daily backups are placed in a folder called current time
echo "------current time is $DATE------"

DAYS=7 # Means to delete a backup from 7 days ago and keep only a backup for 7 days
TAR_BAK="mongod_bak_$DATE.tar.gz"
cd $OUT_DIR

echo '------Delete original backup file------'
rm -rf $OUT_DIR/*

mkdir -p "$OP_DIR"
echo '----Start backing up the database----'


mongodump -h $DB_HOST -u $DB_USER -p $DB_PASS --authenticationDatabase admin -d $DB_NAME -o $OP_DIR --forceTableScan

tar -zcPvf $TAR_DIR/$TAR_BAK $OUT_DIR/$DATE # Compress the current backup file and store it in TAR_DIR

find $TAR_DIR/ -mtime +$DAYS -delete
exit
