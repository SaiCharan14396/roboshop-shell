source common.sh

component=payment
load_schema=false

if [ -z "${roboshop_rabbitmq_password}" ]; then
  echo "variable roboshop_rabbitmq_password is needed"
  exit
fi

PYTHON