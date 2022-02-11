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

function exec_git_clone() {
  repeat_time=50
  git_clone="git clone --recursive https://github.com/${1}.git ${2}"
  git_pull="git pull"
  git_update="git submodule update --init --recursive"
  cd_moduel_directory="cd ${2}"
  cd_back="cd -"
  exit_status=0
  for (( i=1; i<=${repeat_time}; i=i+1 ))
  do
    cmd=${git_clone}
    if [ -s ${2} ];then
      cmd="${cd_moduel_directory} && ${git_pull} && ${git_update} && ${cd_back}"
      echo "command: ${cmd} ............................................ running."
      ${cd_moduel_directory} && ${git_pull} && ${git_update} && ${cd_back}
    else
      echo "command: ${cmd} ............................................ running."
      ${cmd}
    fi
    exit_status=$?
    if [ $(($exit_status)) -ne 0 ]; then
      echo "command: ${cmd} ............................................ error!"
      echo "command: ${cmd} ............................................ retrying.${i}"
    else
      echo "command: ${cmd} ............................................ done!"
      return $(($exit_status))
    fi 
  done
  exit $(($exit_status))
}


function install_vim () {
  vim_source_directory="/usr/local/share/vim"
  vim_directory="/usr/local/vim82"
  vim_git="vim/vim"
  if [ -e ${vim_source_directory} ]; then
    exec_command "rm -rf ${vim_source_directory}"
  fi
  exec_git_clone ${vim_git} ${vim_source_directory}
  exec_command "cd ${vim_source_directory}/src"
  exec_command "./configure --with-features=huge --enable-multibyte --enable-rubyinterp=yes --enable-pythoninterp=yes --enable-python3interp=yes --prefix=${vim_directory}"
  exec_command "make"
  exec_command "make install"
  if [ -e "/usr/bin/vim" ];then
    exec_command "update-alternatives --install /usr/bin/vim vim ${vim_directory}/bin/vim 100"
  else
    exec_command "ln -s ${vim_directory}/bin/vim /etc/alternatives/vim"
    exec_command "ln -s /etc/alternatives/vim /usr/bin/vim"
  fi
  if [ -e "/usr/bin/vimdiff" ];then
    exec_command "update-alternatives --install /usr/bin/vimdiff vim ${vim_directory}/bin/vimdiff 100"
  else
    exec_command "ln -s ${vim_directory}/bin/vimdiff /etc/alternatives/vimdiff"
    exec_command "ln -s /etc/alternatives/vimdiff /usr/bin/vimdiff"
  fi
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
  exec_command "cp -rp .vimrc ${login_user_home}"
  for plugin_git in $(cat ~/.vimrc | grep -e ".*minpac#add.*" | sed "s/.*('\([^,]*\)'.*/\1/g")
  do
    plugin_name=$(echo ${plugin_git} | cut -d'/' -f 2)
    if [ ${plugin_name} == "minpac" ];then
      continue
    fi
    plugin_directory="${2}/.vim/pack/minpac/start/${plugin_name}"
    exec_git_clone ${plugin_git} ${plugin_directory}
  done
}

function install_tools () { 
  login_user=$(echo $HOME | cut -d'/' -f 3)
  login_user_home=$HOME
  require_tools=(
    'git' 
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
  exec_command "apt-get update"
  exec_command "apt-get upgrade"
  for tool in $(echo ${require_tools[*]})
  do
    exec_command "apt-get install $tool -y"
    if [ ${tool} == "git" ];then
      git_installed=1
    fi
    if [ ${tool} == "make" ];then
      make_installed=1
    fi
    if [ ${tool} == "git" ];then
      (
	install_minpac ${login_user} ${login_user_home}
	install_other_plugins ${login_user} ${login_user_home}
	install_ycm ${login_user} ${login_user_home}
      ) &
    fi
  done
  wait
  exec_command "chown -R ${login_user}:${login_user} ${login_user_home}/.vim"
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

install_tools
install_vim 
