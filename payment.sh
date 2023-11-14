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

yum install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "Installing python36"

id roboshop &>> $LOGFILE &>> $LOGFILE

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

mkdir /app &>> $LOGFILE

VALIDATE $? "Creating /app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "Downloading payment.zip"

cd /app &>> $LOGFILE

VALIDATE $? "Navigating to /app directory"

unzip /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "Unziping payment.zip"

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "Installing Requirements from requirement.txt"

cp /home/centos/Roboshop-ShellScript/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon-reload"

systemctl enable payment &>> $LOGFILE

VALIDATE $? "Enable Payment"

systemctl start payment &>> $LOGFILE

VALIDATE $? "Start payment"
