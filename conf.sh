#!/bin/bash

source ./utils.sh

# following env for [go get] command
export GOPROXY=https://goproxy.io

export GO111MODULE=on

exec_command "cd ${login_user_home}/.vim/pack/minpac/start/YouCompleteMe"

exec_command "python3 install.py --all"

exec_command "cd -"

logit "all done!!!" "log"
