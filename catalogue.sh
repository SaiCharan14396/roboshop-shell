script_location=$(pwd)
LOG=/tmp/roboshop.log

echo -e "\e[35m configuring nodejs repos\e[0m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
if [ $? -eq 0 ]; then
  echo success
else
  echo failure
fi

echo -e "\e[35m install nodejs\e[0m"
yum install nodejs -y
if [ $? -eq 0 ]; then
  echo success
else
  echo failure
fi

echo -e "\e[35m add application user\e[0m"
useradd roboshop &>>${LOG}
mkdir -p /app &>>${LOG}
if [ $? -eq 0 ]; then
  echo success
else
  echo failure
fi

echo -e "\e[35m downloading app content\e[0m"
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${LOG}
if [ $? -eq 0 ]; then
  echo success
else
  echo failure
fi

echo -e "\e[35m clean old content\e[0m"
rm -rf /app/* &>>${LOG}
if [ $? -eq 0 ]; then
  echo success
else
  echo failure
fi

echo -e "\e[35m extracting app content\e[0m"
cd /app
unzip /tmp/catalogue.zip &>>${LOG}
if [ $? -eq 0 ]; then
  echo success
else
  echo failure
fi

echo -e "\e[35m installing nodejs dependencies\e[0m"
cd /app
npm install &>>${LOG}
if [ $? -eq 0 ]; then
  echo success
else
  echo failure
fi

echo -e "\e[35m configuring catalogue service file\e[0m"
cp  ${script_location}/files/catalogue.service /etc/systemd/system/catalogue.service &>>${LOG}
if [ $? -eq 0 ]; then
  echo success
else
  echo failure
fi

echo -e "\e[35m reload systemd\e[0m"
systemctl daemon-reload &>>${LOG}
if [ $? -eq 0 ]; then
  echo success
else
  echo failure
fi

echo -e "\e[35m enable catalogue service\e[0m"
systemctl enable catalogue &>>${LOG}
if [ $? -eq 0 ]; then
  echo success
else
  echo failure
fi

echo -e "\e[35m start catalogue service\e[0m"
systemctl start catalogue &>>${LOG}
if [ $? -eq 0 ]; then
  echo success
else
  echo failure
fi

echo -e "\e[35m configuring mongo repo\e[0m"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
if [ $? -eq 0 ]; then
  echo success
else
  echo failure
fi

echo -e "\e[35m install mongo client\e[0m"
yum install mongodb-org-shell -y &>>${LOG}
if [ $? -eq 0 ]; then
  echo success
else
  echo failure
fi

echo -e "\e[35m loa schema\e[0m"
mongo --host mongodb-dev.saicharane.online </app/schema/catalogue.js &>>${LOG}
if [ $? -eq 0 ]; then
  echo success
else
  echo failure
fi

