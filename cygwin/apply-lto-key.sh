#!/bin/bash

RED=$'\e[31m'
GREEN=$'\e[32m'
NORMAL=$'\e[0m'

# Log for err
err() {
	>&2 echo "${RED}${1}${NORMAL}"
}
# Log for good stuff
ok() {
	echo "${GREEN}${1}${NORMAL}"
}

read -s -p "Password: " password
echo

if [ -n "$password" ]; then # password not empty
	read -s -p "Confirm: " password2
	echo
	if [ "$password" != "$password2" ]; then
		err "Password not match."
		exit 1
	fi

	# LTOEnc is a Windows program, not support pipe, 
	# and using `/tmp/something` will cause the filename become a program option.
	# Thus we need put the file on disk shortly
	keyfile=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-20} | head -n 1)
	echo -n $password | sha256sum | awk '{ print $1 }' >> $keyfile
	./LTOEnc /k $keyfile /e mixed
	# record the return code and handle it later
	rc=$?
	# must delete the keyfile
	rm -rf $keyfile
	# now we're handle LTOEnc's return code
	if [ $rc -eq 127 ]; then # command not found from bash
		err "LTOEnc not found!"
		exit 1
	elif [ $rc -ne 0 ]; then # something wrong with LTOEnc
		err "Failed to set encryption mode"
		exit 1	
	fi
	# alter user encryption is on
	ok "Hardware encryption enabled"
else # password is empty, ignore
	err "Password is empty. No encryption applied."
fi
