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


# Install and configure Vim
$vimTmpInstallScript = [System.IO.Path]::GetTempFileName() + '.ps1'
(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/vincpa/vimrc/master/install-vim.ps1', $vimTmpInstallScript)
Invoke-Expression "& `"$vimTmpInstallScript`" $repoPath"

# Create the PowerShell profile directory if it doesn't exist
$powershellProfileDir = [System.IO.Directory]::GetParent($PROFILE).FullName

if (-not (Test-Path $powershellProfileDir)) {
    mkdir $powershellProfileDir
    Write-Host "Created PowerShell profile directory $powershellProfileDir" -ForegroundColor Green
}


# Modules
Install-Module -Name Pscx -Force
Install-Module -Name z -Force
Install-Module -Name Git-PsRadar -Force
Install-Module -Name posh-git -Force


# Symlink config files which are meant to be in the home directory to the repo
New-HardLink "$env:USERPROFILE\.gitignore" "$currentDir\home-config\.gitignore"
New-HardLink "$env:USERPROFILE\.gitconfig" "$currentDir\home-config\.gitconfig"


setEnvVariable "PATH" "d:\gitrepos\psscripts"
setEnvVariable "PATH" '%TOOLS%\UnixUtils'


Write-Host
Write-Host 'PowerShell profile installed. Restart PowerShell for settings to take effect.' -ForegroundColor Yellow
Write-Host
Write-Host "Root Path = $rootPath" -ForegroundColor Green
Write-Host