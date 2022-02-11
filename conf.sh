#!/bin/bash

function logit() {
  exit_status=$?
  LOG_FILE="install.log"
  echo "[`date`] - ${1}" | tee -a ${LOG_FILE}
}

function exec_command() {
  logit "command: ${1} ............................................ running."
  logit $(${1})
  if [ ${exit_status} -ne 0 ]; then
  logit "command: ${1} ............................................ error!"
    exit ${exit_status}
  fi 
  logit "command: ${1} ............................................ done!"
}

login_user=$(who -u | cut -d' ' -f1)
login_user_home=$(cat /etc/passwd | grep ${login_user} | cut -d':' -f6)
exit_status=0

# following env for [go get] command
export GOPROXY=https://goproxy.io
export GO111MODULE=on
exec_command "cd ${login_user_home}/.vim/pack/minpac/start/YouCompleteMe"
exec_command "python3 install.py --all"
logit "all done!!!"
