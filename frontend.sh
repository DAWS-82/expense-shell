#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGS_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"


VALIDATE() {
if [ $1 -ne 0 ]
   then
      echo -e "$2... $R FAILURE $N"
      exit 1
   else
      echo -e "$2... $G SUCCESS $N"
   fi
}


CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "ERROR:: you must have sudo access to execute this script"
        exit 1 #other than 0
    fi
}

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $TIMESTAMP" &>>$LOGS_FILE_NAME

CHECK_ROOT

dnf install nginx -y &>>$LOGS_FILE_NAME
VALIDATE $? "Installing Nginx Server"

systemctl enable nginx &>>$LOGS_FILE_NAME
VALIDATE $? "Enabling Nginx Serrver"

systemctl start nginx &>>$LOGS_FILE_NAME
VALIDATE $? "Starting Nginx server"

rm -rf /usr/share/nginx/html/* &>>$LOGS_FILE_NAME
VALIDATE $? "Removing existing version of code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGS_FILE_NAME
VALIDATE $? "Downloading latest code"

cd /usr/share/nginx/html &>>$LOGS_FILE_NAME
VALIDATE $? "Moving to HTML directory"

unzip /tmp/frontend.zip &>>$LOGS_FILE_NAME
VALIDATE $? "Unzipping the frontend code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copied expense config"

systemctl restart nginx &>>$LOGS_FILE_NAME
VALIDATE $? "Restarting Nginx"


