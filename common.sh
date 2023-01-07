script_location=$(pwd)
LOG=/tmp/roboshop.log

status_check() {
 if [ $? -eq 0 ]; then
   echo -e "\e[32mSUCCESS\e[0m"
 else
   echo -e "\e[31mFAILURE\e[0m"
   echo "refer lof file for more info. LOG FILE PATH : ${LOG}"
   exit
 fi
}

print_head() {
  echo -e "\e[1m $1 \e[0m"
}

NODEJS() {

source common.sh

print_head "configuring nodejs repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
status_check

print_head "install nodejs"
yum install nodejs -y &>>${LOG}
status_check

print_head "add application user"
id roboshop &>>${LOG}
if [ $? -ne 0 ]; then
 useradd roboshop &>>${LOG}
fi
status_check

print_head "create a new directory"
mkdir -p /app &>>${LOG}
status_check

print_head "downloading app content"
curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${LOG}
status_check

print_head "clean old content"
rm -rf /app/* &>>${LOG}
status_check

print_head "extracting app content"
cd /app
unzip /tmp/${component}.zip &>>${LOG}
status_check

print_head "installing nodejs dependencies"
cd /app
npm install &>>${LOG}
status_check

print_head "configuring ${component} service file"
cp  ${script_location}/files/${component}.service /etc/systemd/system/${component}.service &>>${LOG}
status_check

print_head "reload systemd"
systemctl daemon-reload &>>${LOG}
status_check

print_head "enable ${component} service"
systemctl enable ${component} &>>${LOG}
status_check

print_head "start ${component} service"
systemctl start ${component} &>>${LOG}
status_check

if [ ${schema_load} == "true"]; then

  print_head "configuring mongo repo"
  cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
  status_check

  print_head "install mongo client"
  yum install mongodb-org-shell -y &>>${LOG}
  status_check

  print_head "load schema"
  mongo --host mongodb-dev.saicharane.online </app/schema/${component}.js &>>${LOG}
  status_check

fi
}