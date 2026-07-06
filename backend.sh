#!/bin/bash

USERID=$(id -u)

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

############################################
VALIDATE_FUNCTION(){
    if [ $1 -ne 0 ]
then
    echo "$2....FAILURE"
    exit 1
else
    echo "$2...SUCCESS"
fi
}
############################################

echo "Script started executing at:: $TIMESTAMP" &>>$LOG_FILE_NAME

if [ $USERID -ne 0 ]
    then
        echo "ERROR:: You must have SUDO Access to perform this Action" 
        exit 1
    fi

dnf module disable nodejs -y &>>$LOG_FILE_NAME  
VALIDATE_FUNCTION $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE_FUNCTION $? "Enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE_FUNCTION $? "Installing nodejs"

# useradd expense
# VALIDATE_FUNCTION $? "Creating expense user"

mkdir /app
VALIDATE_FUNCTION $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE_FUNCTION $? "downloading application code"

cd /app

unzip /tmp/backend.zip
VALIDATE_FUNCTION $? "unzipping backend application code"

npm install
VALIDATE_FUNCTION $? "Installing dependencies"

cp /home/ec2-user/expense-shell-3/backend.service /etc/systemd/system/backend.service

dnf install mysql -y
VALIDATE_FUNCTION $? "Installing mysql client"

mysql -h mysql.pavancloud5.online -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE_FUNCTION $? "Setting up transcations schema and tables"

systemctl daemon-reload
systemctl enable backend
systemctl restart backend
systemctl start backend
VALIDATE_FUNCTION $? "Starting backend"



