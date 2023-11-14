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

yum module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disabling mysql from yum.repos.d"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "Copying mysql.repo to repos directory"

yum install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "Installing Mysql Server"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "Enabling mysqld"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "Starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "Setting the Password RoboShop@1"
