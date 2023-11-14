#! /bin/bash

LOGDIR=/tmp
DATE=$(date +%F:%H:%M:%S)

LOGFILE=$LOGDIR/$DATE-$0.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE()
{
    if [ $1 -eq 0 ]
    then
        echo -e "$G$2 SUCCESS...$N"
    else
        echo -e "$R$2 FAILED...$N"
    fi
}

USERID=$(id -u)

if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR: Please run the Script with root access$N"
    exit 1
fi

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE

VALIDATE $? "Downloading all repos of redis"

yum module enable redis:remi-6.2 -y &>> $LOGFILE

VALIDATE $? "Enabling redis to redis-6.2 version"

yum install redis -y  &>> $LOGFILE

VALIDATE $? "Installing Redis"

sed -i 's|127.0.0.1|0.0.0.0|g' /etc/redis.conf /etc/redis/redis.conf &>> $LOGFILE

VALIDATE $? "Changing bind Ip address to 0.0.0.0"

systemctl enable redis &>> $LOGFILE

VALIDATE $? "Enabling Redis"

systemctl start redis &>> $LOGFILE

VALIDATE $? "Starting Redis"
