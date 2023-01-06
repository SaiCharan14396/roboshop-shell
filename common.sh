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