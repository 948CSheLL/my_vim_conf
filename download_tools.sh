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

function install_tools () { 
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
  for tool in $(echo ${require_tools[*]})
  do
    exec_command "apt-get install $tool"
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

exec_command "apt-get update"
exec_command "apt-get upgrade"
install_tools
