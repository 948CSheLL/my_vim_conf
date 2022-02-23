#!/bin/bash

source ./utils.sh

(

  install_minpac "${LOGIN_USER_HOME}"

  install_other_plugins "${LOGIN_USER_HOME}"

  exec_command "chown -R ${LOGIN_USER}:${LOGIN_USER} ${LOGIN_USER_HOME}/.vim" "${CMD_CHOWN}"

) &

install_tools

wait

install_vim 

echo "./download_tools.sh all done !!!" | tee -a ${LOG_FILE}
