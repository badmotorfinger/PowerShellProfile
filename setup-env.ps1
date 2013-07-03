#Run this script the first time you log on to a machine you've never logged on to before.

#$env:path.IndexOf('Chocolatey', [System.StringComparison]::OrdinalIgnoreCase) -gt 0

$currentDir = Split-Path $MyInvocation.MyCommand.Definition

Write-Host "Current directory is $currentDir"

$powershellProfileDir = [System.IO.Directory]::GetParent($PROFILE).FullName

if (-not (Test-Path $powershellProfileDir)) {
    mkdir $powershellProfileDir
}

$rootPath = [System.IO.Directory]::GetParent($currentDir).Parent

Get-Content -Path "$currentDir\Microsoft.PowerShell_profile.ps1" | 
	% { $_.Replace('%rootPath%', $rootPath.FullName) } | Set-Content $PROFILE

$moduleRoot = $env:PSModulePath.Split(";")[0]

if (-not (Test-Path $moduleRoot)) {
	md -Path $env:PSModulePath.Split(";")[0]
}

# Modules
if ( -not (get-module pscx)) {
	
	$pscxDir = Join-Path $moduleRoot 'Pscx'
	
	if (-not (Test-Path $pscxDir)) {
		md -Path $pscxDir
	}
	Copy-Item "..\Modules\Pscx" -Dest $moduleRoot -Recurse -Force -Verbose
}

if ( -not (get-module powertab)) {

	$ptDir = Join-Path $moduleRoot 'PowerTab'

	if (-not (Test-Path $ptDir)) {
		md -Path $ptDir
	}
	Copy-Item "..\Modules\PowerTab" -Dest $moduleRoot -Recurse -Force -Verbose
}

if ( -not (get-module z)) {

	$ptDir = Join-Path $moduleRoot 'z'

	if (-not (Test-Path $ptDir)) {
		md -Path $ptDir
	}
	Copy-Item "..\z" -Dest $moduleRoot -Recurse -Force -Verbose
}

if ( -not (get-module ShowCalendar)) {

	$ptDir = Join-Path $moduleRoot 'ShowCalendar'

	if (-not (Test-Path $ptDir)) {
		md -Path $ptDir
	}
	Copy-Item "..\Modules\ShowCalendar" -Dest $moduleRoot -Recurse -Force -Verbose
}

Write-Host 'PowerShell profile installed. Restart PowerShell for settings to take effect.' -ForegroundColor Yellow