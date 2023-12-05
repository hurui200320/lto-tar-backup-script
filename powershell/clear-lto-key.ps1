#Requires -RunAsAdministrator

$ltoenc = 'C:\LTOEnc.exe'

&$ltoenc /e off
if ($LASTEXITCODE -ne 0) {
	Write-Host "LTOEnc command failed!" -ForegroundColor red
	Exit 1
} else {
	Write-Host "Cleared! The encryption led should be off" -ForegroundColor green
}