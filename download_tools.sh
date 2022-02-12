#!/bin/bash

source ./utils.sh

(

  install_minpac ${login_user} ${login_user_home}

  install_other_plugins ${login_user} ${login_user_home}

  install_ycm ${login_user} ${login_user_home}

  exec_command "chown -R ${login_user}:${login_user} ${login_user_home}/.vim"

) &

install_tools

wait

install_vim 
