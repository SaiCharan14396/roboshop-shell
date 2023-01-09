source common.sh

if [ -z "${roboshop_rabbitmq_password}" ]; then
  echo "variable roboshop_rabbitmq_password is needed"
  exit
fi

print_head "configuring erlang YUM repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>>${LOG}
status_check

print_head "configuring rabbitmq YUM repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${LOG}
status_check

print_head "install erlang and rabbitmq"
yum install erlang rabbitmq-server -y &>>${LOG}
status_check

print_head "enable rabbitmq-server"
systemctl enable rabbitmq-server &>>${LOG}
status_check

print_head "start rabbitmq-server"
systemctl start rabbitmq-server &>>${LOG}
status_check

print_head "add rabbitmq user"
rabbitmqctl list users | grep roboshop
if [ $? -ne 0 ]; then
  rabbitmqctl add_user roboshop roboshop_rabbitmq_password &>>${LOG}
fi
status_check

print_head "set tag for rabbitmq user"
rabbitmqctl set_user_tags roboshop administrator &>>${LOG}
status_check

print_head "set permissions for rabbitmq user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG}
status_check
