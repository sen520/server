#! /bin/bash

DB_HOST='' # mongo host
DB_NAME='data'

OUT_DIR='/root/alpha/mongod_bak_now' #临时目录
TAR_DIR='/root/alpha/mongod_bak_list' # 备份存放路径

DB_USER='' # mongo username
DB_PASS='' # mongo user password

DATE=$(date +'%Y-%m-%d') # 获取当前系统时间

OP_DIR="$OUT_DIR/$DATE" # 每天的备份放在一个文件夹中
echo "------当前时间为$DATE------"

DAYS=7 # 代表删除7天前的备份，只保留7天的备份
TAR_BAK="mongod_bak_$DATE.tar.gz"
cd $OUT_DIR

echo '------删除原有备份文件------'
rm -rf $OUT_DIR/*

mkdir -p "$OP_DIR"
echo '----开始备份数据库----'


mongodump -h $DB_HOST -u $DB_USER -p $DB_PASS --authenticationDatabase admin -d $DB_NAME -o $OP_DIR --forceTableScan

tar -zcPvf $TAR_DIR/$TAR_BAK $OUT_DIR/$DATE

find $TAR_DIR/ -mtime +$DAYS -delete
exit
