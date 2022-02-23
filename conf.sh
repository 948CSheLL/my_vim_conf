#!/bin/bash

source ./utils.sh

exec_command "cd ${LOGIN_USER_HOME}/.vim/pack/minpac/start/YouCompleteMe" "${CMD_CD}"

exec_command "python3 install.py --all" "${CMD_PYTHON3}"

exec_command "cd -" "${CMD_CD}"

echo "./conf.sh all done !!!" | tee -a ${LOG_FILE}
