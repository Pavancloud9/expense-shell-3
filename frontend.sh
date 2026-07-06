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

dnf install nginx -y
VALIDATE_FUNCTION $? "Installing Nginx"

systemctl enable nginx
VALIDATE_FUNCTION $? "Enabling Nginx"

systemctl start nginx
VALIDATE_FUNCTION $? "Starting Nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE_FUNCTION "Removing default nginx page"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE_FUNCTION $? "downloading frontend application code"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip
VALIDATE_FUNCTION $? "Unzipping frontend code"

cp /home/ec2-user/expense-shell-3/expense.conf /etc/nginx/default.d/expense.conf

systemctl restart nginx
VALIDATE_FUNCTION $? "Restarting Nginx"
