#Run this script the first time you log on to a machine you've never logged on to before.
cls

# The location of utilities
$rootPath =         'E:\CloudStation'
# The location of programing languages
$rootDevLangPath  = 'C:\dev\lang'
$rootDevToolsPath = 'E:\CloudStation\tools'
$scriptsPath      = 'D:\gitrepos\scripts'

$jdkVersion       = 'jre1.8.0_45'
$antVersion       = '1.9.4'
$gradleVersion    = '2.6'
$rubyVersion      = '22-x64'


if (-not (Test-Path -Path $rootPath)) {
	  #$rootPath = "$env:USERPROFILE\
    if (-not (Test-Path -Path $rootPath)) {
        Write-Host "Could not find root path $rootPath" -ForegroundColor Red
        return
    }
}

if (-not (Test-Path -Path $rootDevToolsPath)) {
    Write-Host "Could not find root development tools path $rootDevToolsPath" -ForegroundColor Red
    return
}

if (-not (Test-Path -Path $rootDevLangPath)) {
    Write-Host "Could not find root languages path $rootDevLangPath" -ForegroundColor Magenta
}


$currentDir = Split-Path $MyInvocation.MyCommand.Definition

Write-Host "Current directory is $currentDir"


Write-Host 'Installing Chocolatey...' -ForegroundColor Green
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

# Install Packages
choco install python2
choco install git
choco install nodejs


Write-Host 'Installing npm modules...' -ForegroundColor Green
npm install -g firstaidgit
Write-Host


Write-Host "Installing fonts for vim and powerline..." -NoNewLine
$FONTS = 0x14
$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace($FONTS)
$objFolder.CopyHere("$currentDir\PragmataPro.ttf")
$objFolder.CopyHere("$currentDir\Inconsolata for Powerline.otf")
$objFolder.CopyHere("$currentDir\PragmataPro for Powerline.ttf")
Write-Host "done."

Write-Host 'Installing powerline for vim...' -ForegroundColor Green
c:
cd \python27\scripts
pip install powerline-status

# Create the PowerShell profile directory if it doesn't exist
$powershellProfileDir = [System.IO.Directory]::GetParent($PROFILE).FullName

if (-not (Test-Path $powershellProfileDir)) {
    mkdir $powershellProfileDir
    Write-Host "Created PowerShell profile directory $powershellProfileDir" -ForegroundColor Green
}

# If the profile file is not named Microsoft.PowerShell_profile.ps1 then the profile won't load.
$profileFullPath = Join-Path -Path $powershellProfileDir -ChildPath "Microsoft.PowerShell_profile.ps1"

Get-Content -Path "$currentDir\Microsoft.PowerShell_profile.ps1" |
	% { $_.Replace('%rootPath%', $rootPath) } |
    % { $_.Replace('%rootDevPath%', $rootDevPath) } | Set-Content $profileFullPath

Write-Host "Wrote profile to $profileFullPath" -ForegroundColor Green


$moduleRoot = $env:PSModulePath.Split(";")[0]

if (-not (Test-Path $moduleRoot)) {
	md -Path $moduleRoot
    Write-Host "Created PowerShell module directory $moduleRoot" -ForegroundColor Green
}


# Clear the current user PATH variable as it's going to be reset below
[System.Environment]::SetEnvironmentVariable('PATH', '', [System.EnvironmentVariableTarget]::User)

# A function for copying PowerShell modules so they can be loaded in a session
function CopyModule
{
	param($moduleName, $startingPath = '..\Modules\')

    $startingPath = ($startingPath.TrimEnd('\') + '\')

    $sourcePath = Join-Path -Path $startingPath -ChildPath $moduleName

    if ((Test-Path $sourcePath)) {

	    $ptDir = Join-Path $moduleRoot $moduleName

	    if (-not (Test-Path $ptDir)) {
		    md -Path $ptDir
	    }
	    Copy-Item ($startingPath + $moduleName) -Dest $moduleRoot -Recurse -Force

    } else {
        Write-Host "Could not find source module $sourcePath" -ForegroundColor Red
    }
}

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
Install-Module -Name Pscx
Install-Module -Name z
Install-Module -Name Git-PsRadar
Install-Module -Name posh-git
Install-Module -Name PSReadline

$Env:TOOLS = "$rootPath\tools"
setEnvVariable "TOOLS" $Env:TOOLS


setEnvVariable "PATH" $Env:TOOLS
setEnvVariable "PATH" "$scriptsPath\psscripts"
setEnvVariable "PATH" (Join-Path $Env:TOOLS "\UnixUtils")
setEnvVariable "PATH" (Join-Path $Env:TOOLS "\SysinternalsSuite")
setEnvVariable "PATH" (Join-Path $Env:TOOLS "\Remote Desktop Connection Manager")

# NodeJS
setEnvVariable "PATH" 'C:\Program Files\nodejs\'
setEnvVariable "PATH" "$env:USERPROFILE\AppData\Roaming\npm"
setEnvVariable "NODE_PATH" "$env:USERPROFILE\AppData\Roaming\npm"

# curl
setEnvVariable "PATH" "$rootDevToolsPath\curl"

# git
setEnvVariable "GIT_HOME" 'C:\Program Files\Git'
setEnvVariable "PATH" 'C:\Program Files\Git\cmd'
setEnvVariable "PATH" 'C:\Program Files\Git\mingw64\bin'
setEnvVariable "PATH" 'C:\Program Files\Git\usr\bin'

setEnvVariable "PATH" 'C:\Program Files\gs\gs9.19\bin'

# Go lang
setEnvVariable "PATH" (Join-Path $rootDevLangPath "\go\bin")
setEnvVariable "GOROOT" (Join-Path $rootDevLangPath "\go")

# Python
setEnvVariable "PATH" 'C:\Python27'
setEnvVariable "PATH" 'C:\Python27\scripts'

# Ruby
setEnvVariable "PATH" (Join-Path $rootDevLangPath "\Ruby$rubyVersion\bin")

# Android
setEnvVariable "ANDROID_NDK_PATH" "$rootDevToolsPath\Android\android_ndk"
setEnvVariable "ANDROID_SDK_HOME" "$rootDevToolsPath\Android\android_sdk"
setEnvVariable "ANDROID_HOME" "$rootDevToolsPath\Android\android_sdk"
setEnvVariable "ADT_HOME" "$rootDevToolsPath\Android\android_sdk"
setEnvVariable "PATH" "$rootDevToolsPath\Android\android_sdk\tools"
setEnvVariable "PATH" "$rootDevToolsPath\Android\android_sdk\platform-tools"


# Java
setEnvVariable "JAVA_HOME" "C:\Program Files\Java\jdk$jdkVersion"
setEnvVariable "JDK_HOME" "C:\Program Files\Java\jdk$jdkVersion"
setEnvVariable "PATH" "C:\Program Files\Java\jdk$jdkVersion\bin"

# Gradle
setEnvVariable "PATH" (Join-Path $rootDevToolsPath "\gradle-$gradleVersion\bin")

# Ant
setEnvVariable "ANT_HOME" (Join-Path $rootDevToolsPath "\apache-ant-$antVersion")
setEnvVariable "PATH" (Join-Path $rootDevToolsPath "\apache-ant-$antVersion\bin")

# Vim
setEnvVariable "VIM" (Join-Path $Env:TOOLS 'Vim')

Write-Host
Write-Host 'PowerShell profile installed. Restart PowerShell for settings to take effect.' -ForegroundColor Yellow
Write-Host
Write-Host "Root Path = $rootPath" -ForegroundColor Green
Write-Host "Root Languages Path = $rootDevLangPath" -ForegroundColor Green
Write-Host "Root Development Tools Path = $rootDevToolsPath" -ForegroundColor Green
Write-Host
