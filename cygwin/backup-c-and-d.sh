#!/bin/bash

RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
NORMAL=$'\e[0m'

TAPE=/dev/nst0
# Block size = BLOCK * 512, 2MB per record.
# This will waste a lot of space with small files,
# hopefully the compression will fix it.
# Large block size will feed more data to drive and keep it spinning
BLOCK=4096

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

# backup a drive under /cygwin
backup() {
	echo "Starting backup ${1}..."
	# Pipe in Cygwin performs very bad, thus we have to write to tape drive directly
	tar -b $BLOCK --exclude *.tmp --exclude-from $folder/backup-exclude.txt -cf $TAPE ${1}
	if [ $? -eq 2 ]; then
		err "Tar command has a fatal error when backup ${1}"
	fi
	mt -f $TAPE tell
	ok "${1} backup finished!"
}

folder=$(PWD)

echo "Preparing tape drive $TAPE"
# enable compression
mt -f $TAPE compression 2
checkError "Need power from admin!! Exit..."
# Rewind to block 0
echo "Rewinding..."
mt -f $TAPE rewind
checkError "Failed to rewind"

cd /cygdrive
checkError "Failed to change directory to /cygdrive"


backup c
backup d


# write the eof again, two will end the tape
mt -f $TAPE weof 1
checkError "Failed to finish tape with another EOF marker"
# reset compression
mt -f $TAPE compression 0

ok "Done!"