#!/bin/bash

sudo ./download_tools.sh $@

./conf.sh $@

echo "all done !!!" | tee -a ${LOG_FILE}
