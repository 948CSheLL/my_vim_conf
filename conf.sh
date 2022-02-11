#!/bin/bash

function logit() {
  LOG_FILE="install.log"
  echo "[`date`] - ${1}" | tee -a ${LOG_FILE}
}

function exec_command() {
  logit "command: ${1} ............................................ running."
  logit $(${1})
  exit_status=$?
  if [ $(($exit_status)) -ne 0 ]; then
  logit "command: ${1} ............................................ error!"
    exit $(($exit_status))
  fi 
  logit "command: ${1} ............................................ done!"
}

# following env for [go get] command
export GOPROXY=https://goproxy.io
export GO111MODULE=on
exec_command "cd $HOME/.vim/pack/minpac/start/YouCompleteMe"
exec_command "python3 install.py --all"
logit "all done!!!"
