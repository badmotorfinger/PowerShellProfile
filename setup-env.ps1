#Run this script the first time you log on to a machine you've never logged on to before.
cls

$rootPath =         'C:\Users\Vince\OneDrive'
$rootDevLangPath  = 'C:\lang'
$rootDevToolsPath = "$rootPath\tools"
$repoPath         = 'C:\dev'
$scriptsPath      = "$repoPath\scripts"

$jdkVersion       = 'jre1.8.0_45'
$antVersion       = '1.9.4'
$gradleVersion    = '2.6'


if (-not (Test-Path -Path $rootPath)) {
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

$currentDir = Split-Path $MyInvocation.MyCommand.Definition

Write-Host "Current directory is $currentDir"


Write-Host 'Installing Chocolatey & packages...' -ForegroundColor Green
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

choco install python2 --limit-output -y
choco install git --limit-output -y
choco install nodejs --limit-output -y
choco install ruby --limit-output -y
choco install sysinternals --limit-output -y
choco install winmerge --limit-output -y
choco install rdcman --limit-output -y


# Add some tools to path after install as other tools rely on it.
setEnvVariable "PATH" 'C:\Program Files\Git\cmd'    # Set here for externally called scripts
$Env:Path = $Env:Path + 'C:\Program Files\Git\cmd'  # Set here for this script
$Env:Path = $Env:Path + ';C:\Python27\scripts'
$Env:Path = $Env:Path + ';C:\Program Files\nodejs'
# RefreshEnv doesn't seem to work but we'll call it anyway as chocolatey recommends it
RefreshEnv

Write-Host 'Installing npm modules...' -ForegroundColor Green
npm update -g
npm install -g firstaidgit
Write-Host

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


$Env:TOOLS = "$rootPath\tools"
setEnvVariable "TOOLS" $Env:TOOLS

setEnvVariable "PATH" "$scriptsPath\psscripts"
setEnvVariable "PATH" '%TOOLS%\UnixUtils'

# curl
setEnvVariable "PATH" "$rootDevToolsPath\curl"

# Android
# setEnvVariable "ANDROID_NDK_PATH" "$rootDevToolsPath\Android\android_ndk"
# setEnvVariable "ANDROID_SDK_HOME" "$rootDevToolsPath\Android\android_sdk"
# setEnvVariable "ANDROID_HOME" "$rootDevToolsPath\Android\android_sdk"
# setEnvVariable "ADT_HOME" "$rootDevToolsPath\Android\android_sdk"
# setEnvVariable "PATH" "$rootDevToolsPath\Android\android_sdk\tools"
# setEnvVariable "PATH" "$rootDevToolsPath\Android\android_sdk\platform-tools"

# Java
# setEnvVariable "JAVA_HOME" "C:\Program Files\Java\jdk$jdkVersion"
# setEnvVariable "JDK_HOME" "C:\Program Files\Java\jdk$jdkVersion"
# setEnvVariable "PATH" "C:\Program Files\Java\jdk$jdkVersion\bin"

# Gradle
# setEnvVariable "PATH" (Join-Path $rootDevToolsPath "\gradle-$gradleVersion\bin")

# Ant
# setEnvVariable "ANT_HOME" (Join-Path $rootDevToolsPath "\apache-ant-$antVersion")
# setEnvVariable "PATH" (Join-Path $rootDevToolsPath "\apache-ant-$antVersion\bin")

Write-Host
Write-Host 'PowerShell profile installed. Restart PowerShell for settings to take effect.' -ForegroundColor Yellow
Write-Host
Write-Host "Root Path = $rootPath" -ForegroundColor Green
Write-Host "Root Languages Path = $rootDevLangPath" -ForegroundColor Green
Write-Host "Root Development Tools Path = $rootDevToolsPath" -ForegroundColor Green
Write-Host
