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

yum install golang -y &>> $LOGFILE

VALIDATE $? "Installing golang"

id roboshop &>> $LOGFILE

if [ $? -eq 0 ]
then
    echo -e "$R roboshop user already exists$N"
    exit 1
fi

useradd roboshop &>> $LOGFILE

VALIDATE $? "Creating Roboshop User"

ls /app &>> $LOGFILE

if [ $? -eq 0 ]
then
    echo -e "$R app directory  already exists$N"
    exit 1
fi

mkdir /app

VALIDATE $? "Creating App Directory"

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOGFILE

VALIDATE $? "Downloading dispatch.zip in tmp directory"

cd /app &>> $LOGFILE

VALIDATE $? "Navigating to app directory"

unzip /tmp/dispatch.zip &>> $LOGFILE

VALIDATE $? "Unzip dipatch.zip"

go mod init dispatch &>> $LOGFILE

VALIDATE $? "go mod"

go get &>> $LOGFILE

VALIDATE $? "go get"

go build &>> $LOGFILE

VALIDATE $? "go build"

cp /home/centos/Roboshop-ShellScript/dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE

VALIDATE $? "Copying dispatch.service to systemd directory"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon-reload"

systemctl enable dispatch &>> $LOGFILE

VALIDATE $? "Enable Dispatch" 

systemctl start dispatch &>> $LOGFILE

VALIDATE $? "Start Dispatch"
