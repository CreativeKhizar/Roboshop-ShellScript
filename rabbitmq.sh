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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "Installing rpm for downloading RabbitMQ"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "Repos for RabbitMQ"

yum install rabbitmq-server -y  &>> $LOGFILE

VALIDATE $? "Installing RabbitMQ"

systemctl enable rabbitmq-server &>> $LOGFILE

VALIDATE $? "Enabling rabbitmq"

systemctl start rabbitmq-server &>> $LOGFILE

VALIDATE $? "Starting Rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE

VALIDATE $? "Add user roboshop in rabbitmq"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE

VALIDATE $? "Adding permssionto rabbitmq"