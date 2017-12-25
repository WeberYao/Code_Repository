#!/bin/bash
# a nginx access log segmentation shell script

echo "PID of this script: $$"

function cutNginxLog(){
        log_dir="/data/logs/nginx"
	    backup_dir="/data/logs/nginx/backup"
        cd ${log_dir}
        time=`date +%Y%m%d`
       
        #日志分割，按天分类
        #website=`ls $log_dir/access* |grep "log$" |xargs -n 1 |cut -d "." -f 2,3,4`
        website=`ls $log_dir/*.log|awk -F'/' '{print $NF}'`
        for i in $website
        do
          mkdir -p $log_dir/backup/$time/
          mv $log_dir/$i $log_dir/backup/$time/${time}_${i}
        done
        /etc/init.d/nginx reload

        #/usr/bin/7za a $time.7z $time
        #tar zcvf $time.tar.gz  $time
        #rm -rf $time
        #删除前15天的日志文件
        find $backup_dir -type f -name '*.log' -mtime +15 -exec rm -rf {} \;
        #find /data/logs/nginx/access/backup/  -name "*.tar.gz" -mtime +1 | xargs -i rm -rf {};
} 

cutNginxLog

