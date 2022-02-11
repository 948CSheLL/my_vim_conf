#!/bin/bash

source ./utils.sh

login_user=$(who -u | cut -d' ' -f1)

login_user_home=$(cat /etc/passwd | grep ${login_user} | cut -d':' -f6)

LOG_FILE="install.log"

exit_status=0

# following env for [go get] command
export GOPROXY=https://goproxy.io

export GO111MODULE=on

exec_command "cd ${login_user_home}/.vim/pack/minpac/start/YouCompleteMe"

exec_command "python3 install.py --all"

logit "all done!!!" "log"
