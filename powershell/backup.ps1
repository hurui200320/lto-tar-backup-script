#Requires -RunAsAdministrator

$tape_device = 'TAPE0'
$tape_dir = 'E:'
$7z = 'C:\7za\7za.exe'
$7z_exclude = @(
	"-x@$(Resolve-Path .\backup-exclude.txt)", 
	"-xr@$(Resolve-Path .\backup-recursive-exclude.txt)"
)
$7z_option = @(
	'-ttar', '-snh', '-snl'
)

function Compress {
    param (
        [string]$SourcePath,
        [string]$FileName
    )
	
	# somehow my powershell stop output stdout from 7z
	# have to redirect them into stderr
	& $7z a $7z_option $7z_exclude $tape_dir\$FileName $SourcePath
	
    if ($LASTEXITCODE -eq 0) {
        Write-Host "7z $SourcePath Success" -ForegroundColor green
    } else {
        Write-Host "7z $SourcePath Failed" -ForegroundColor yellow
    }
}

Write-Host "This script will backup C and D drive to tape drive $tape_device mounting at $tape_dir." -ForegroundColor yello
Write-Host "Now we're going to reformat the LTFS volume and do compression." -ForegroundColor yello
Write-Host "All data on tape drive $tape_device and $tape_dir will be permanently deleted." -ForegroundColor red
$r = Read-Host "Proceed? Press Ctrl-C to exit; Press enter to continue"
if ($r) {
	Write-Host "Did not press enter, exit..." -ForegroundColor red
	Exit 1
}

# Format LTFS
Write-Host "Formating LTFS drive: $tape_device"
$date = Get-Date -Format "yyyyMMddHHmmZ" -AsUTC
Invoke-Expression "mkltfs --device=$tape_device -f -n $date"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to format LTFS drive, exit..." -ForegroundColor red
    Exit 1
}

# waiting for LTFS mount
Write-Host "Format success. Waiting for LTFS mount at $tape_dir..."
while($true) {
	Get-ChildItem $tape_dir -ErrorAction SilentlyContinue
	if ($?) {
		break
	} else {
		Write-Host "Waiting for LTFS mount at $tape_dir..."
		Start-Sleep -Seconds 5
	}
}
Write-Host "Waiting another 10s..."
Start-Sleep -Seconds 10

# backup
Write-Host "Start backup"
Compress -SourcePath 'C:\' -FileName 'C.tar'
Compress -SourcePath 'D:\' -FileName 'D.tar'

# done
Write-Host "Done" -ForegroundColor green
