#!/bin/bash

function logit() {

  echo "[`date`] - ${1}" >> ${LOG_FILE}

  if [ $(($?)) -ne 0 ];then

    exit $(($?))

  fi

}

function handle_retry() {
  
  logit "command: ${1} ............................................ error, exit_status: ${2}"

  logit "command: ${1} ............................................ retrying."

}

function handle_error() {

  logit "command: ${1} ............................................ error, exit_status: ${2}"

  exit ${2}

}

function handle_done() {

    logit "command: ${1} ............................................ done!"

}

function handle_exit_status() {

  exit_status=$((${2}))

  if [ ${exit_status} -eq 128 ] && ([ "${3}" == "${CMD_GIT_CLONE}" ]);then

    handle_retry "${1}" "${exit_status}"

  elif [ ${exit_status} -eq 1 ] && ([ "${3}" == "${CMD_GIT_PULL}" ] || [ "${3}" == "${CMD_GIT_CLONE}" ] || [ "${3}" == "${CMD_GIT_UPDATE}" ] || [ "${3}" == "${CMD_PYTHON3}" ]);then 

    handle_retry "${1}" "${exit_status}"

  elif [ ${exit_status} -eq 100 ] && ([ "${3}" == "${CMD_APT_INSTALL}" ] || [ "${3}" == "${CMD_APT_UPDATE}" ] || [ "${3}" == "${CMD_APT_UPGRADE}" ]);then 

    handle_retry "${1}" "${exit_status}"

  elif [ ${exit_status} -ne 0 ]; then

    handle_error "${1}" "${exit_status}"

  elif [ ${exit_status} -eq 0 ];then

    handle_done "${1}"

  fi 

  return ${exit_status}

}

# shell 函数中return 和echo 都可以返回值，混用要小心，如果使用return 来返回
# 需要的值，返回之不能超过255，主函数需要通过$? 来引用。
function exec_command() {

  logit "command: ${1} ............................................ running."

  for (( i=1; i<=${CMD_REPEAT}; i=i+1 ))
  do

    ${1} 2>> ${LOG_FILE}

    handle_exit_status "${1}" "$?" "${2}"

    isdone=$(($?))

    if [ ${isdone} -eq 0 ];then

      break

    fi

  done

  return ${isdone}

}


function exec_git_clone() {

  git_clone="git clone --recursive https://github.com/${1}.git ${2}"

  git_pull="git pull"

  git_update="git submodule update --init --recursive"

  cd_moduel_directory="cd ${2}"

  cd_back="cd -"

  for (( i=1; i<=${GIT_REPEAT}; i=i+1 ))
  do

    isdone=0

    cmd=${git_clone}

    if [ -s ${2} ];then

      cmd="${cd_moduel_directory} && ${git_pull} && ${git_update} && ${cd_back}"

      logit "command: ${cmd} ............................................ running."

      exec_command "${cd_moduel_directory}" "${CMD_CD}"

      isdone=$(( ${isdone} + $(($?)) ))

      exec_command "${git_pull}" "${CMD_GIT_PULL}"

      isdone=$(( ${isdone} + $(($?)) ))

      exec_command "${git_update}" "${CMD_GIT_UPDATE}"

      isdone=$(( ${isdone} + $(($?)) ))

      exec_command "${cd_back}" "${CMD_CD}"

      isdone=$(( ${isdone} + $(($?)) ))

    else

      exec_command "${cmd}" "${CMD_GIT_CLONE}"

      isdone=$(($?))

    fi

    if [ ${isdone} -eq 0 ];then

      break

    fi


  done

}


function install_vim () {

  vim_source_directory="/usr/local/share/vim"

  vim_directory="/usr/local/vim82"

  vim_git="948CSheLL/vim"

  if [ -e "${vim_source_directory}" ]; then

    exec_command "rm -rf ${vim_source_directory}" "${CMD_RM}"

  fi

  exec_git_clone ${vim_git} ${vim_source_directory}

  exec_command "cd ${vim_source_directory}/src" "${CMD_CD}"

  exec_command "./configure --with-features=huge --enable-multibyte --enable-rubyinterp=yes --enable-pythoninterp=yes --enable-python3interp=yes --prefix=${vim_directory}" "${CMD_CONFIGURE}"

  exec_command "make" "${CMD_MAKE}"

  exec_command "make install" "${CMD_MAKE}"

  exec_command "cd -" "${CMD_CD}"

  if [ -e "/etc/alternatives/vim" ];then

    exec_command "rm /etc/alternatives/vim" "${CMD_RM}"

  fi

  exec_command "ln -s ${vim_directory}/bin/vim /etc/alternatives/vim" "${CMD_LN}"

  if [ -e "/usr/bin/vim" ];then

    exec_command "rm /usr/bin/vim" "${CMD_RM}"

  fi

  exec_command "ln -s /etc/alternatives/vim /usr/bin/vim" "${CMD_LN}"

  if [ -e "/usr/bin/vimdiff" ];then

    exec_command "rm /usr/bin/vimdiff" "${CMD_RM}"

  fi

  exec_command "ln -s /etc/alternatives/vimdiff /usr/bin/vimdiff" "${CMD_LN}"

  if [ -e "/etc/alternatives/vimdiff" ];then

    exec_command "rm /etc/alternatives/vimdiff" "${CMD_RM}"

  fi

  exec_command "ln -s ${vim_directory}/bin/vimdiff /etc/alternatives/vimdiff" "${CMD_LN}"

}

function install_minpac () {

  minpac_git="k-takata/minpac"

  minpac_directory="${2}/.vim/pack/minpac/opt/minpac"

  exec_git_clone "${minpac_git}" "${minpac_directory}"

}

function install_other_plugins() {

  exec_command "cp -rp .vimrc ${2}" "${CMD_CP}"

  for plugin_git in $(cat ${2}/.vimrc | grep -e ".*minpac#add.*" | sed "s/.*('\([^,]*\)'.*/\1/g")
  do

    plugin_name="$(echo "${plugin_git}" | cut -d'/' -f 2)"

    if [ "${plugin_name}" == "minpac" ];then

      continue

    fi

    plugin_directory="${2}/.vim/pack/minpac/start/${plugin_name}"

    exec_git_clone "${plugin_git}" "${plugin_directory}"

  done

}

function install_tools () { 

  require_tools=(

    'make'

    'libgtk2.0-dev'

    'libgnome2-dev'

    'libxt-dev'    

    'libx11-dev'   

    'python3-dev'

    'build-essential'

    'python3-pip'

    'clang-7'

    'clang-10'

    'libclang-10-dev'

    'clangd-10'

    'gcc-8'

    'g++-8'

    'golang-1.13'

    'libstdc++-8-dev'

    'libpthread-*'

    'mono-complete'

    'nodejs'

    'default-jdk'

    'npm'

  )

  exec_command "apt-get update -y" "${CMD_APT_UPDATE}"

  exec_command "apt-get upgrade -y" "${CMD_APT_UPGRADE}"

  for tool in $(echo "${require_tools[*]}")

  do

    exec_command "apt-get install $tool -y" "${CMD_APT_INSTALL}"

  done

  # using pip3 install latest cmake

  exec_command "pip3 install cmake" "${CMD_PIP}"

  # alternate original gcc

  exec_command "update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 100" "${CMD_UPDATE_ALTERNATIVES}"

  # alternate original g++

  exec_command "update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 100" "${CMD_UPDATE_ALTERNATIVES}"

  # alternate original clang

  exec_command "update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 100" "${CMD_UPDATE_ALTERNATIVES}"

  # alternate original clang++

  exec_command "update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-7 100" "${CMD_UPDATE_ALTERNATIVES}"

  # alternate original clangd

  exec_command "update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-10 100" "${CMD_UPDATE_ALTERNATIVES}"

  # alternate original golang

  exec_command "update-alternatives --install /usr/bin/go go /usr/lib/go-1.13/bin/go 100" "${CMD_UPDATE_ALTERNATIVES}"

}

LOG_FILE="$(pwd)/install.log"

GIT_REPEAT=10

CMD_REPEAT=5

CMD_UPDATE_ALTERNATIVES="1"

CMD_CD="2"

CMD_GIT_PULL="3"

CMD_GIT_UPDATE="4"

CMD_APT_UPDATE="5"

CMD_APT_UPGRADE="6" 

CMD_APT_INSTALL="7" 

CMD_CHOWN="8" 

CMD_RM="9" 

CMD_GIT_CLONE="10" 

CMD_MAKE="11"

CMD_CONFIGURE="12"

CMD_LN="13"

CMD_CP="14"

CMD_PIP="15"

CMD_PYTHON3="16"

for var in ${@}
do

  option="$(echo "${var}" | cut -d'=' -f1)"

  value="$(echo "${var}" | cut -d'=' -f2)"

  if [ "${option}" == "--GIT_REPEAT" ] && [ -n "${value}" ];then

    GIT_REPEAT=$((${value}))

  elif [ "${option}" == "--CMD_REPEAT" ] && [ -n "${value}" ];then

    CMD_REPEAT=$((${value}))

  elif [ "${option}" == "--LOG_FILE" ] && [ -n "${value}" ];then

    LOG_FILE="${value}"

  elif [ "${option}" == "--help" ];then

    echo "Usage: ./install.sh [[--CMD_REPEAT] [--GIT_REPEAT] [--LOG_FILE] | [--help]]"

    echo "Download tools for vim and plugins"

    echo "	--GIT_REPEAT 	Set the number of times the git command execution will "

    echo "			try again if it encounters a network error."

    echo "	--CMD_REPEAT 	Set the number of times the shell command execution "

    echo "			will try again if it encounters a network error."

    echo "	--LOG_FILE 	Set the absolute path of log file."

    exit 0

  fi

done

LOGIN_USER="$(who -u | cut -d' ' -f1)"

LOGIN_USER_HOME="$(cat /etc/passwd | grep ${LOGIN_USER} | cut -d':' -f6)"

exec_command "chown ${LOGIN_USER}:${LOGIN_USER} ${LOG_FILE}" "${CMD_CHOWN}"
