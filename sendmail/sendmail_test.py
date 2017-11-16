#!/usr/bin/env python
# -*- coding: UTF-8 -*-


import sys
import os
import smtplib
from email.mime.text import MIMEText
from email.message import Message

HOST='smtp.126.com'
PORT=25
USER='yaoweber@126.com'
PASS='Yao..123..'
TO='yaoweibiao@doojaa.com'
LOG_PATH='/backup/logs'

# 输入目录路径，输出最新文件完整路径
def find_new_file(dir):
    '''查找目录下最新的文件'''
    file_lists = os.listdir(dir)
    file_lists.sort(key=lambda fn: os.path.getmtime(dir + "/" + fn) if not os.path.isdir(dir + "/" + fn) else 0)
    '''最新的文件'''
    newest_file_name = file_lists[-1]
    '''最新的文件:完整路径'''
    newest_file_path = os.path.join(dir, file_lists[-1])
    result=[newest_file_name,newest_file_path]
    return result



def get_content(LOG_FILE):
    ret = []
    with open(LOG_FILE, 'r') as f:
        for line in f:
            if 'started' in line:
                ret = []
            else:
                ret.append(line)
    return ''.join(ret)

if __name__ == "__main__":
    smtp = smtplib.SMTP(local_hostname=HOST)
    smtp.set_debuglevel(1)
    smtp.connect(HOST, PORT)
    smtp.login(USER, PASS)
    result = find_new_file(LOG_PATH)
    msg = MIMEText(get_content(result[1]))
    msg['Subject'] = 'Backup LOG:'+ result[0]
    msg['From'] = USER
    msg['To'] = TO

    smtp.sendmail(USER, TO, msg.as_string())
    print 'sendmail done.'

