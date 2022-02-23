#!/bin/bash

source ./utils.sh

# following env for [go get] command
export GOPROXY=https://goproxy.io

export GO111MODULE=on

exec_command "cd ${LOGIN_USER_HOME}/.vim/pack/minpac/start/YouCompleteMe" "${CMD_CD}"

exec_command "python3 install.py --all" "${CMD_PYTHON3}"

exec_command "cd -" "${CMD_CD}"

echo "./conf.sh all done !!!" | tee -a ${LOG_FILE}
