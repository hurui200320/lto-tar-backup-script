#!/bin/bash

RED=$'\e[31m'
GREEN=$'\e[32m'
NORMAL=$'\e[0m'

# Log for err
err() {
	>&2 echo "${RED}${1}${NORMAL}"
}

./LTOEnc /e off
rc=$?
# now we're handle LTOEnc's return code
if [ $rc -eq 127 ]; then # command not found from bash
	err "LTOEnc not found!"
	exit 1
elif [ $rc -ne 0 ]; then # something wrong with LTOEnc
	err "Failed to set encryption mode"
	exit 1	
fi
# alter user encryption is on
echo "${GREEN}Hardware encryption key is cleared${NORMAL}"
