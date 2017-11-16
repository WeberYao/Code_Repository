#!/bin/bash
#
# Description: Mysql 5.6.x for CentOS backup databases
# 
# Auther: Weber Date: 2017/11/11 

#backup path
FULL_BACKUP_PATH=/backup/full
INCR_BACKUP_PATH=/backup/incr
LSNS_BACKUP_PATH=/backup/lsns
LAST_FULL_BACKUP=`ls $FULL_BACKUP_PATH| sort | tail -1`

MYSQL_CNF_PATH=/usr/local/mysql/etc/my.cnf
MYSQL_USER="root"
MYSQL_PWD="rootroot"
SOCKET_PATH="/tmp/mysql.sock"
LOG_PATH="/backup/logs/"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
PORT="3306"

# 获取CPU核心数和内存大小
INS_CPU_COUNT=` cat /proc/cpuinfo | grep 'processor' | wc -l `
INS_MEM_SIZE=` cat /proc/meminfo | grep MemTotal | awk  '{print $2}' `

# 根据CPU和内存来判断并行编译进程
if [ $INS_CPU_COUNT -ge '8' ] && [ $INS_MEM_SIZE -lt '8196000' ]; then
	MAKE_JOBS='4'
else
	MAKE_JOBS='2'
fi

#before backup need to check the path env.
mysql_path_check()
{
    if [ ! -d $FULL_BACKUP_PATH ];then
        mkdir -p $FULL_BACKUP_PATH
    fi
    
    if [ ! -d $INCR_BACKUP_PATH ];then
        mkdir -p $INCR_BACKUP_PATH
    fi
    
    if [ ! -d $LSNS_BACKUP_PATH ];then
        mkdir -p $LSNS_BACKUP_PATH
    fi
}

#check the mysql status
check_mysql_status()
{
    mysql_status=netstat -nltp | awk 'NR>2{if ($4 ~ /.*:3306/) {print "Yes";exit0}}'
    
    if ["$mysql_status" != "Yes"];then
        error "Mysql do not bind on port 3306 or do not start."
    fi
}

# backup satrt
innobackup_full_backup()
{  
    innobackupex --defaults-file=$MYSQL_CNF_PATH --user=$MYSQL_USER --password=$MYSQL_PWD $FULL_BACKUP_PATH --port=$PORT --socket=$SOCKET_PATH >${LOG_PATH}full_${DATE}.log 2>&1 > /dev/null

}

# backup satrt
innobackup_incr_backup()
{  
    innobackupex --defaults-file=$MYSQL_CNF_PATH --user=$MYSQL_USER --password=$MYSQL_PWD --port=$PORT  --socket=$SOCKET_PATH  --incremental-basedir=${FULL_BACKUP_PATH}/${LAST_FULL_BACKUP} --incremental $INCR_BACKUP_PATH >${LOG_PATH}incr_${DATE}.log 2>&1 > /dev/null

}

#remove over 7 days old backup files
remove_expire_backup()
{
    find . -mtime +7 -name "*.log" -exec rm -rf {} \;
}

# Main Program
case $1 in 
    0) innobackup_full_backup
    ;;
    1) innobackup_incr_backup
    ;;
esac

remove_expire_backup

