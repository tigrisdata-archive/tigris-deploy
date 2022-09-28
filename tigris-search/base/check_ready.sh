#!/usr/bin/env bash

TSHOST=localhost
TSPORT=8108

INFO=$(curl -s ${TSHOST}:${TSPORT}/health)
echo "${INFO}" | egrep '"ok":true'
RETCODE=$?
if [ ${RETCODE} -gt 0 ]; then
    echo "/health endpoint responded with ${INFO}"
fi
exit ${RETCODE}
