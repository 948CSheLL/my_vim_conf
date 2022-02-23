#!/bin/bash

sudo bash download_tools.sh $@ --LOGIN_USER=$LOGNAME --LOGIN_USER_HOME=$HOME

exit_status=$(($?))

if [ ${exit_status} -ne 0 ];then

  exit ${exit_status}

fi

bash conf.sh $@

exit_status=$(($?))

if [ ${exit_status} -ne 0 ];then

  exit ${exit_status}

fi

echo "all done !!!" | tee -a ${LOG_FILE}
