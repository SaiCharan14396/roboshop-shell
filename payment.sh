source common.sh

component=payment
schema_load=false

if [ -z "${roboshop_rabbitmq_password}" ]; then
  echo "variable roboshop_rabbitmq_password is needed"
  exit
fi

PYTHON