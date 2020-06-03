$currentDir = Split-Path $MyInvocation.MyCommand.Definition

# Look in both Program Files directories to find a child path
function Get-ProgramPath($path, $childPath) {

    if ($path -ne $null -and $path.StartsWith('C:\Program Files')) {

        if ((Test-Path $path)) {
            return $path
        } else {

            $tmpPath = $path.Replace('C:\Program Files', 'C:\Program Files (x86)')
            if ((Test-Path $tmpPath)) {
                return $tmpPath
            }
        }
    }
    return $path
}

# Set environment variable. If it's PATH, check if the path exists before adding it.
function setEnvVariable($name, $value, $checkPath = $true)
{
    $value = Get-ProgramPath $value

    if ($name -eq "PATH") {

        if ($value -eq $null) {
            Write-Host "Could not find path $value. Not added to PATH." -ForegroundColor Magenta
            return;
        }

       $existingValue = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
	    if ($existingValue -eq $null) {
	  	    $existingValue = ''
	    }

        $value = $value.TrimEnd(';').TrimEnd('\')

        if ($existingValue -contains $value) {
            return;
        }

	    $value = $existingValue.TrimEnd(';').TrimEnd('\') + ";" + $value

    } else {
        if (-not $value.StartsWith("%") -and $checkPath -and (Test-Path -Path $value -IsValid) -and -not (Test-Path $value)) {

            Write-Host "Could not find path $value. Environment variable $name not created." -ForegroundColor Magenta
            return;
        }
    }

    [System.Environment]::SetEnvironmentVariable($name, $value, [System.EnvironmentVariableTarget]::User)
    Write-Host "Set name $name and value $value" -ForegroundColor Green
}

# Modules
Install-Module -Name Pscx -Force -AllowClobber
Install-Module -Name z -Force -AllowClobber
Install-Module -Name Git-PsRadar -Force
Install-Module -Name posh-git -Force

# Symlink config files which are meant to be in the home directory to the repo

New-Item -ItemType HardLink -Path "$env:USERPROFILE\.gitignore" -Target "$currentDir\config\.gitignore"
New-Item -ItemType HardLink -Path "$env:USERPROFILE\.gitconfig" -Target "$currentDir\config\.gitconfig"
New-Item -ItemType HardLink -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Target "$currentDir\Microsoft.PowerShell_profile.ps1"

# setEnvVariable "PATH" "d:\gitrepos\psscripts"
# setEnvVariable "PATH" '%TOOLS%\UnixUtils'
# setEnvVariable "PATH" '%USERPROFILE%\AppData\Roaming\Python\Scripts'
