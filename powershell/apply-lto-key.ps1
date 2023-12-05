#Requires -RunAsAdministrator

$ltoenc = 'C:\LTOEnc.exe'


function sha256 {
	Param (
		[Parameter(Mandatory=$true)]
		[string]
		$ClearString
	)

	$hasher = [System.Security.Cryptography.HashAlgorithm]::Create('sha256')
	$hash = $hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($ClearString))

	$hashString = [System.BitConverter]::ToString($hash)
	$hashString.Replace('-', '').ToLower()
}

# asking password
$pwd_string = Read-Host "Password" -MaskInput
if ($pwd_string) {
	$pwd_cfm_string = Read-Host "Confirm" -MaskInput 
	if ($pwd_string -ne $pwd_cfm_string) {
		Write-Host "Passsword not match" -ForegroundColor red
		Exit 1		
	}
	$hash = sha256 $pwd_string
	Out-File -FilePath .\key.tmp -InputObject $hash -NoNewline
	&$ltoenc /k (Resolve-Path .\key.tmp) /e on
	$rc = $LASTEXITCODE
	Remove-Item .\key.tmp -Force
	if ($rc -ne 0) {
		Write-Host "LTOEnc command failed!" -ForegroundColor red
		Exit 1
	} else {
		Write-Host "Setup success, please check the blue led on tape drive" -ForegroundColor green
	}
} else {
	Write-Host "Empty passsword!" -ForegroundColor red
}
