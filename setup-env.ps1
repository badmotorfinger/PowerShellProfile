#Run this script the first time you log on to a machine you've never logged on to before.

$currentDir = Split-Path $MyInvocation.MyCommand.Definition

$powershellProfileDir = [System.IO.Directory]::GetParent($PROFILE).FullName

if (-not (Test-Path $powershellProfileDir)) {
    mkdir $powershellProfileDir
}

$parent = [System.IO.Directory]::GetParent($currentDir)

Get-Content -Path "$currentDir\Microsoft.PowerShell_profile.ps1" | % { $_.Replace("%toolspath%", $parent.FullName).Replace("%utilspath%", ($parent.Parent.FullName + "\utils")) } | Set-Content $PROFILE

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
	Copy-Item "..\psscripts\Modules\Pscx" -Dest $moduleRoot -Recurse -Force -Verbose
}

if ( -not (get-module powertab)) {

	$ptDir = Join-Path $moduleRoot 'PowerTab'

	if (-not (Test-Path $ptDir)) {
		md -Path $ptDir
	}
	Copy-Item "..\psscripts\Modules\PowerTab" -Dest $moduleRoot -Recurse -Force -Verbose
}

. $PROFILE