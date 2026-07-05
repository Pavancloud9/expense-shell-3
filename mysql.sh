#!/bin/bash

USERID=$(id -u)

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S)
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

dnf install mysql-server -y
VALIDATE_FUNCTION $? "Installing MYSQL-server" 

systemctl enable mysqld
VALIDATE_FUNCTION $? "Enabling MYSQL-server"

systemctl start mysqld
VALIDATE_FUNCTION $? "Starting MYSQL-server"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE_FUNCTION $? "Setting root password"

  
