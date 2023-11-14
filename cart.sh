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

yum install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing Nodejs"

id roboshop &>> $LOGFILE

if [ $? -eq 0 ]
then
    echo -e "$R roboshop user already exists$N"
    exit 1
fi

useradd roboshop &>> $LOGFILE

VALIDATE $? "Adding roboshop cart"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Downloading cart.zip"

ls /app &>> $LOGFILE

if [ $? -eq 0 ]
then
    echo -e "$R app directory  already exists$N"
    exit 1
fi

mkdir /app &>> $LOGFILE

VALIDATE $? "Creating app directory"

cd /app &>> $LOGFILE

VALIDATE $? "Navigating to app Directory"

unzip /tmp/cart.zip &>> $LOGFILE

VALIDATE $? "Unzipping cart.zip"

npm install &>> $LOGFILE

VALIDATE $? "npm install"

cp /home/centos/Roboshop-ShellScript/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "Copying cart.service to system"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon reload"

systemctl enable cart &>> $LOGFILE

VALIDATE $? "Enable cart"

systemctl start cart &>> $LOGFILE

VALIDATE $? "Start Cart"
