#!/bin/bash

function exec_command() {
  echo "command: ${1} ............................................ running."
  ${1}
  exit_status=$?
  if [ $(($exit_status)) -ne 0 ]; then
  echo "command: ${1} ............................................ error!"
    exit $(($exit_status))
  fi 
  echo "command: ${1} ............................................ done!"
}

# following env for [go get] command
export GOPROXY=https://goproxy.io
export GO111MODULE=on
exec_command "cd $HOME/.vim/pack/minpac/start/YouCompleteMe"
exec_command "python3 install.py --all"
echo "all done!!!"
