#!/bin/bash

export LOGIN_USER=$LOGNAME

export LOGIN_USER_HOME=$HOME

# following env for [go get] command
export GOPROXY=https://goproxy.io

export GO111MODULE=on


sudo ./download_tools.sh $@

exit_status=$(($?))

if [ ${exit_status} -ne 0 ];then

  exit ${exit_status}

fi

./conf.sh $@

exit_status=$(($?))

if [ ${exit_status} -ne 0 ];then

  exit ${exit_status}

fi

echo "all done !!!" | tee -a ${LOG_FILE}
