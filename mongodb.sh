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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copying mongo.repo file into repos Directory"

yum install mongodb-org -y &>> $LOGFILE

VALIDATE $? "Installing Mongodb Server"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "Enabling mongodb server"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "Starting mongodb Server"

sed -i 's|127.0.0.1|0.0.0.0|g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "Changing the bind IpAddress from 127.0.0.1 to 0.0.0.0"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarting the mongdb Server"
