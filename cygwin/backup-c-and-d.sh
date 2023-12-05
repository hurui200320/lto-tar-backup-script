#!/bin/bash

RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
NORMAL=$'\e[0m'

TEMP_FOLDER=${1:-/tmp}
echo "Using temp dir: $TEMP_FOLDER"
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
	# I notice the pipe in Cygwin perform very bad
	# thus need to write somewhere and then dd from disk
	# other wise can only get 70MB/s while tape drive can do 160MB/s
	tar -b $BLOCK --zstd --exclude *.tmp --exclude-from $folder/backup-exclude.txt -cf - ${1} | dd of=$TEMP_FOLDER/${1}.tmp bs=4M status=progress
	dd if=g/${1} of=$TAPE bs=4M status=progress
	if [ $? -eq 2 ]; then
		err "Tar command has a fatal error when backup ${1}"
	fi
	mt -f $TAPE tell
	rm -rf $TEMP_FOLDER/${1}.tmp
	ok "${1} backup finished!"
}

folder=$(PWD)

echo "Preparing tape drive $TAPE"
# disable compression, we're using zstd
mt -f $TAPE compression 0
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

ok "Done!"