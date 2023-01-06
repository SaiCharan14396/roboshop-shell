script_location=$(pwd)
LOG=/tmp/roboshop.log

echo -e "\e[35m install nginx \e[0m"
yum install nginx -y &>>${LOG}
echo $?

echo -e "\e[35m remove nginx old content \e[0m"
rm -rf /usr/share/nginx/html/* &>>${LOG}
echo $?

echo -e "\e[35m download frontend content \e[0m"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${LOG}
echo $?

cd /usr/share/nginx/html &>>${LOG}

echo -e "\e[35m extract frontend content \e[0m"
unzip /tmp/frontend.zip &>>${LOG}
echo $?

echo -e "\e[35m copy roboshop nginx config file \e[0m"
cp  ${script_location}/files/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf &>>${LOG}
echo $?

echo -e "\e[35m enable nginx \e[0m"
systemctl enable nginx &>>${LOG}
echo $?

echo -e "\e[35m start nginx \e[0m"
systemctl restart nginx &>>${LOG}
echo $?
