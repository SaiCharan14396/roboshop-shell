source common.sh

print_head "copy mongo db repo file"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
status_check

print_head "install mongo db"
yum install mongodb-org -y &>>${LOG}
status_check

print_head "install mongo db listener address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>${LOG}
status_check

#systemctl operations
print_head "enable mongo db"
systemctl enable mongod &>>${LOG}
status_check

print_head "restart mongo db"
systemctl restart mongod &>>${LOG}
status_check



