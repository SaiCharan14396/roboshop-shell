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

APP_PREREQ() {

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

}

SYSTEMD_SETUP() {

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


}

LOAD_SCHEMA() {
  if [ ${schema_load} == "true" ]; then
    if [ ${schema_type} == "mongo" ]; then
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

    if [ ${schema_type} == "mysql" ]; then

          print_head "install mysql client"
          yum install mysql -y &>>${LOG}
          status_check

          print_head "load schema"
          mysql -h mysql-dev.saicharane.online -uroot -p${root_mysql_password} < /app/schema/shipping.sql  &>>${LOG}
          status_check
    fi
  fi

}


NODEJS() {

source common.sh

print_head "configuring nodejs repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
status_check

print_head "install nodejs"
yum install nodejs -y &>>${LOG}
status_check

APP_PREREQ

print_head "installing nodejs dependencies"
cd /app
npm install &>>${LOG}
status_check

SYSTEMD_SETUP

LOAD_SCHEMA

}

MAVEN() {

print_head "install maven"
yum install maven -y &>>${LOG}
status_check

APP_PREREQ

print_head "build a package"
mvn clean package &>>${LOG}
status_check

print_head "copy app file to app location"
mv target/${component}-1.0.jar ${component}.jar &>>${LOG}
status_check

SYSTEMD_SETUP

LOAD_SCHEMA

}

PYTHON() {

print_head "install python"
yum install python36 gcc python3-devel -y &>>${LOG}
status_check

APP_PREREQ

print_head "download dependencies"
cd /app
pip3.6 install -r requirements.txt &>>${LOG}
status_check

print_head "update password in service file"
sed -i -e "s//${roboshop_rabbitmq_password}/" ${script_location}/files/${component}.service &>>${LOG}
status_check


SYSTEMD_SETUP

LOAD_SCHEMA

}