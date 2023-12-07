# PowerShell
These are scripts for running in PowerShell.

Note: Those scripts requires PowerShell 7.4 or later running as administrator. When backing up C drive, you need extra permission to visit a folder.

## Status

Windows suck. I change back to cygwin.

## Requirement

+ PowerShell 7.4 or later running as administrator
+ [LTOEnc](https://github.com/VulpesSARL/LTOEnc) placed at `C:\LTOEnc.exe`
+ `7za` placed at `C:\7za\7za.exe` along with its dependencies
+ `mkltfs` in the PATH
+ Tape drive mount to `E:`

## Usage

If you prefer hardware encryption, use `apply-lto-key.ps1` script to setup. DO THIS BEFORE MOUNTING THE LTFS. Also, you have to insert a tape before setting things up.

Then mount the tape drive using LTFS configurator or something your vendor gives you. Now it might notice you that the tape is encrypted or cannot be read. Don't worry, you may do this later.

Run `backup.ps1`. This script will format the tape with LTFS and use UTC date as volume name, so you know when this backup is done. By doing so, the tape now has a valid LTFS encrypted. Now you can try mount it again. The tool should not complain. And don't worry, the script will wait for you. This script will backup the C drive (windows drive) and D drive (my one and only one data drive). To ignore root folders, change the content in `backup-exclude.txt`. To ignore content recursively, edit `backup-recursive-exclude.txt`. Check those files before use.

After finish, use `clear-lto-key.ps1` to reset hardware encryption.

## Recover

Use `tar -tvf E:\C.tar` to test the tar file. Windows has a tar builtin, but it's bsdtar. Bad for creating archive file, but good enough to extract files.
