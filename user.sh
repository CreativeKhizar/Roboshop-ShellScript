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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE

VALIDATE $? "Downloading Npm Sources"

yum install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing Nodejs"

id roboshop &>> $LOGFILE

if [ $? -eq 0 ]
then
    echo -e "$R roboshop user already exists$N"
    exit 1
fi

useradd roboshop &>> $LOGFILE

VALIDATE $? "Adding roboshop user"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloading user.zip"

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

unzip /tmp/user.zip &>> $LOGFILE

VALIDATE $? "Unzipping user.zip"

npm install &>> $LOGFILE

VALIDATE $? "npm install"

cp /home/centos/Roboshop-ShellScript/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "Copying user.service to system"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enable user"

systemctl start user &>> $LOGFILE

VALIDATE $? "Start User"

cp /home/centos/Roboshop-ShellScript/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copying mongo.repo to yum.repos.d"

yum install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installin mongo client"

mongo --host mongodb.buyrobos.online </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading data to mongodb"