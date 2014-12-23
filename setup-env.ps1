#Run this script the first time you log on to a machine you've never logged on to before.

$rootPath = 'C:\Users\Vince\OneDrive'
$rootDevPath = 'C:\dev\'
$currentDir = Split-Path $MyInvocation.MyCommand.Definition

Write-Host "Current directory is $currentDir"

$powershellProfileDir = [System.IO.Directory]::GetParent($PROFILE).FullName

if (-not (Test-Path $powershellProfileDir)) {
    mkdir $powershellProfileDir
}

Get-Content -Path "$currentDir\Microsoft.PowerShell_profile.ps1" |
	% { $_.Replace('%rootPath%', $rootPath) } |
    % { $_.Replace('%rootDevPath%', $rootDevPath) } | Set-Content $PROFILE

Write-Host "Wrote profile to $PROFILE"

$moduleRoot = $env:PSModulePath.Split(";")[0]

if (-not (Test-Path $moduleRoot)) {
	md -Path $env:PSModulePath.Split(";")[0]
}

function CopyModule
{
	param($moduleName, $startingPath = '..\Modules\')

	$ptDir = Join-Path $moduleRoot $moduleName

	if (-not (Test-Path $ptDir)) {
		md -Path $ptDir
	}
	Copy-Item ($startingPath + $moduleName) -Dest $moduleRoot -Recurse -Force
}

# Modules
CopyModule 'Pscx'
CopyModule 'PowerTab'
CopyModule 'z' '..\'
CopyModule 'ShowCalendar'
CopyModule 'posh-git'
CopyModule 'PSReadLine'

Write-Host
Write-Host 'PowerShell profile installed. Restart PowerShell for settings to take effect.' -ForegroundColor Yellow
Write-Host
Write-Host "Root Path = $rootPath" -ForegroundColor Green
Write-Host "Root Development Path = $rootDevPath" -ForegroundColor Green
Write-Host
