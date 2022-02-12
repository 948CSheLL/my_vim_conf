#!/bin/bash

function logit() {

  exit_status=0

  echo "[`date`] - ${1}" >> ${log_file}

  exit_status=$(($?))

  if [ ${exit_status} -ne 0 ];then

    exit ${exit_status}

  fi

}

function handle_exit_status() {

  exit_status=$(($?))

  if [ ${exit_status} -eq 128 ];then

    logit "command: ${1} ............................................ error, exit: ${exit_status}"

    logit "command: ${cmd} ............................................ retrying.${i}"

  elif [ ${exit_status} -ne 0 ]; then

    logit "command: ${1} ............................................ error, exit: ${exit_status}"

    exit ${exit_status}

  elif [ ${exit_status} -eq 0 ];then

    logit "command: ${1} ............................................ done!"

  fi 

  return ${exit_status}

}

# shell 函数中return 和echo 都可以返回值，混用要小心，如果使用return 来返回
# 需要的值，返回之不能超过255，主函数需要通过$? 来引用。
function exec_command() {

  logit "command: ${1} ............................................ running."

  isdonw=0

  for (( i=1; i<=${cmd_repeat}; i=i+1 ))
  do

    ${1} 2>> ${log_file}

    handle_exit_status "${1}"

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

  for (( i=1; i<=${git_repeat}; i=i+1 ))
  do

    isdone=0

    cmd=${git_clone}

    if [ -s ${2} ];then

      cmd="${cd_moduel_directory} && ${git_pull} && ${git_update} && ${cd_back}"

      logit "command: ${cmd} ............................................ running."

      exec_command "${cd_moduel_directory}"

      isdone=$(( ${isdone} + $(($?)) ))

      exec_command "${git_pull}"

      isdone=$(( ${isdone} + $(($?)) ))

      exec_command "${git_update}"

      isdone=$(( ${isdone} + $(($?)) ))

      exec_command "${cd_back}"

      isdone=$(( ${isdone} + $(($?)) ))

    else

      logit "command: ${cmd} ............................................ running."

      exec_command "${cmd}"

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

  vim_git="vim/vim"

  if [ -e "${vim_source_directory}" ]; then

    exec_command "rm -rf ${vim_source_directory}"

  fi

  exec_git_clone ${vim_git} ${vim_source_directory}

  exec_command "cd ${vim_source_directory}/src"

  exec_command "./configure --with-features=huge --enable-multibyte --enable-rubyinterp=yes --enable-pythoninterp=yes --enable-python3interp=yes --prefix=${vim_directory}"

  exec_command "make"

  exec_command "make install"

  exec_command "cd -"

  if [ -e "/etc/alternatives/vim" ];then

    exec_command "rm /etc/alternatives/vim"

  fi

  exec_command "ln -s ${vim_directory}/bin/vim /etc/alternatives/vim"

  if [ -e "/usr/bin/vim" ];then

    exec_command "rm /usr/bin/vim"

  fi

  exec_command "ln -s /etc/alternatives/vim /usr/bin/vim"

  if [ -e "/usr/bin/vimdiff" ];then

    exec_command "rm /usr/bin/vimdiff"

  fi

  exec_command "ln -s /etc/alternatives/vimdiff /usr/bin/vimdiff"

  if [ -e "/etc/alternatives/vimdiff" ];then

    exec_command "rm /etc/alternatives/vimdiff"

  fi

  exec_command "ln -s ${vim_directory}/bin/vimdiff /etc/alternatives/vimdiff"

}

function install_minpac () {

  minpac_git="k-takata/minpac"

  minpac_directory="${2}/.vim/pack/minpac/opt/minpac"

  exec_git_clone ${minpac_git} ${minpac_directory}

}

function install_ycm() {

  ycm_git="948CSheLL/YouCompleteMe" 

  ycm_directory="${2}/.vim/pack/minpac/start/YouCompleteMe"

  exec_git_clone ${ycm_git} ${ycm_directory}

}

function install_other_plugins() {

  exec_command "cp -rp .vimrc ${2}"

  for plugin_git in $(cat ${2}/.vimrc | grep -e ".*minpac#add.*" | sed "s/.*('\([^,]*\)'.*/\1/g")
  do

    plugin_name=$(echo "${plugin_git}" | cut -d'/' -f 2)

    if [ "${plugin_name}" == "minpac" ];then

      continue

    fi

    plugin_directory="${2}/.vim/pack/minpac/start/${plugin_name}"

    exec_git_clone ${plugin_git} ${plugin_directory}

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

  exec_command "apt-get update -y"

  exec_command "apt-get upgrade -y"

  for tool in $(echo "${require_tools[*]}")

  do

    exec_command "apt-get install $tool -y"

  done

  # using pip3 install latest cmake

  exec_command "pip3 install cmake"

  # alternate original gcc

  exec_command "update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 100"

  # alternate original g++

  exec_command "update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 100"

  # alternate original clang

  exec_command "update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 100"

  # alternate original clang++

  exec_command "update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-7 100"

  # alternate original clangd

  exec_command "update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-10 100"

  # alternate original golang

  exec_command "update-alternatives --install /usr/bin/go go /usr/lib/go-1.13/bin/go 100"

}

log_file="$(pwd)/install.log"

git_repeat=10

cmd_repeat=5

for var in ${@}
do

  option=$(echo "${var}" | cut -d'=' -f1)

  value=$(echo "${var}" | cut -d'=' -f2)

  if [ "${option}" == "--git_repeat" ] && [ -n ${value} ];then

    git_repeat=$((${value}))

  elif [ "${option}" == "--cmd_repeat" ] && [ -n ${value} ];then

    cmd_repeat=$((${value}))

  elif [ "${option}" == "--log_file" ] && [ -n ${value} ];then

    log_file="${value}"

  elif [ "${option}" == "--help" ];then

    echo "Usage: ./install.sh [[--cmd_repeat] [--git_repeat] [--log_file] | [--help]]"

    echo "Download tools for vim and plugins"

    echo "	--git_repeat 	Set the number of times the git command execution will "

    echo "			try again if it encounters a network error."

    echo "	--cmd_repeat 	Set the number of times the shell command execution "

    echo "			will try again if it encounters a network error."

    echo "	--log_file 	Set the absolute path of log file."

    exit 0

  fi

done

login_user=$(who -u | cut -d' ' -f1)

login_user_home=$(cat /etc/passwd | grep ${login_user} | cut -d':' -f6)

exec_command "chown ${login_user}:${login_user} ${log_file}"
