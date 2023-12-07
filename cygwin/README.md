# Cygwin
These are scripts for running in Cygwin.

Note: Those scripts requires Cygwin running as administrator. Command `mt` and `LTOEnc` need those power to control the tape drive.

## Issue

When testing, `dd if=file of=/dev/nst0 bs=4M` gives full speed (160MB/s), but then using `dd if=file bs=8M | dd of=/dev/nst0 bs=4M` gives only half the speed (65MB/s). I assume the pipe implementation is hard/bad on windows.

Currently I let tar write directly to the `/dev/nst0`, thus losing the ability to track progress.

## Requirement

+ Cygwin running as administrator
+ [LTOEnc](https://github.com/VulpesSARL/LTOEnc) placed in same folder (if you want to use hardware encryption)

## Usage

If you prefer hardware encryption, then use `apply-lto-key.sh` script to setup. The script will ask your password twice and only setup tape drive if two passwords are match.

Then use `backup-c-and-d.sh`, it will backup the C drive (windows drive) and D drive (my one and only one data drive). To ignore folders, change the content in `backup-exclude.txt`. By default it exclude the Windows folder and other NTFS folders like `System Volume Information`. Check this file before use.

After finish, use `clear-lto-key.sh` to reset hardware encryption.

## Data on tape

```
ccccccccc*dddddddddd**-------------------
```

`c` means C drive tar ball, `*` means EOF marker, `d` means D drive tar ball, `-` means no use.

## Recover

Use `tar -b 2048 -tvf /dev/nst0` to test the tar file. The option `-b 2048` is required.
