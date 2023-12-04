#!/bin/bash

RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
NORMAL=$'\e[0m'

TAPE=/dev/nst0
# Block size = BLOCK * 512, 1MB per record.
# This will waste a lot of space with small files,
# hopefully the compression will fix it.
# Large block size will feed more data to drive and keep it spinning
BLOCK=2048

# Log for err
err() {
	>&2 echo "${RED}${1}${NORMAL}"
}
# Log for warning
warn() {
	echo "${YELLOW}${1}${NORMAL}"
}
# Log for good stuff
ok() {
	echo "${GREEN}${1}${NORMAL}"
}
# check $? and throw err if not return 0
checkError(){
	if [ $? -ne 0 ]; then
		err "${1:-"Last command failed, exit..."}"
		exit 1
	fi
}

folder=$(PWD)

echo "Preparing tape drive $TAPE"
# enable compression
mt -f $TAPE compression 2
checkError "Need power from admin!! Exit..."
# Rewind to block 0
mt -f $TAPE rewind
checkError "Failed to enable compression"

cd /cygdrive
checkError "Failed to change directory to /cygdrive"

echo "Starting backup C drive..."
# backup c drive, but not Windows folder
tar -b $BLOCK --exclude-from $folder/backup-exclude.txt -cf $TAPE c 
if [ $? -eq 2 ]; then
	# NOTE: tar will return 2 if some file cannot be opened.
	# 		Here we just alert user and not crash.
	err "Tar command has a fatal error when backup C drive"
fi
mt -f $TAPE tell
ok "C drive backup finished!"

echo "Starting backup D drive..."
# backup d drive
tar -b $BLOCK --exclude-from $folder/backup-exclude.txt -cf $TAPE d
if [ $? -eq 2 ]; then
	err "Tar command has a fatal error when backup D drive"
fi
mt -f $TAPE tell
ok "D drive backup finished!"

# write the eof again, two will end the tape
mt -f $TAPE weof 1
checkError "Failed to finish tape with another EOF marker"

# disable encryption and compress
echo "Cleaning up..."
mt -f $TAPE compression 0

ok "Done!"