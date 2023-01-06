source common.sh

print_head "configuring nodejs repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
status_check

print_head "install nodejs"
yum install nodejs -y &>>${LOG}
status_check

print_head "add application user"
id roboshop &>>${LOG}
if [ $? -ne 0]; then
 useradd roboshop &>>${LOG}
fi
status_check

print_head "create a new directory"
mkdir -p /app &>>${LOG}
status_check

print_head "downloading app content"
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${LOG}
status_check

print_head "clean old content"
rm -rf /app/* &>>${LOG}
status_check

print_head "extracting app content"
cd /app
unzip /tmp/catalogue.zip &>>${LOG}
status_check

print_head "installing nodejs dependencies"
cd /app
npm install &>>${LOG}
status_check

print_head "configuring catalogue service file"
cp  ${script_location}/files/catalogue.service /etc/systemd/system/catalogue.service &>>${LOG}
status_check

print_head "reload systemd"
systemctl daemon-reload &>>${LOG}
status_check

print_head "enable catalogue service"
systemctl enable catalogue &>>${LOG}
status_check

print_head "start catalogue service"
systemctl start catalogue &>>${LOG}
status_check

print_head "configuring mongo repo"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
status_check

print_head "install mongo client"
yum install mongodb-org-shell -y &>>${LOG}
status_check

print_head "load schema"
mongo --host mongodb-dev.saicharane.online </app/schema/catalogue.js &>>${LOG}
status_check
