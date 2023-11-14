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

yum install maven -y &>> $LOGFILE

VALIDATE $? "Installing maven"
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

VALIDATE $? "Creating App Directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "Downloading shipping.zip"

cd /app &>> $LOGFILE

VALIDATE $? "Navigating to app directory"

unzip /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "Unzipping shipping.zip"

mvn clean package &>> $LOGFILE

VALIDATE $? "Creating package"

cp /home/centos/Roboshop-ShellScript/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "Copying shipping.service to system"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon-reload"

systemctl enable shipping  &>> $LOGFILE

VALIDATE $? "Enable Shipping"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "Start Shipping"

yum install mysql -y  &>> $LOGFILE

VALIDATE $? "Installing mysql"

mysql -h mysql.buyrobos.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

VALIDATE $? "Loading data to mysql"

systemctl restart shipping &>> $LOGFILE

VALIDATE $? "Restarting shipping"
