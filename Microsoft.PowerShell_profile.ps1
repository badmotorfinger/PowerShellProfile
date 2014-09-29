##############################################################################
##
## Vince Panuccio's custom PowerShell prompt.
##
##############################################################################

$rootPath = '%rootPath%'
$rootDevPath = '%rootDevPath%'

$toolsPath = "$rootPath\tools"
$utilsPath = "$rootPath\utils"
$gitPath = "$toolsPath\git"
$scriptsPath = "$rootPath\psscripts"
$hgPath = "$toolsPath\mercurial"

[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + $toolsPath, "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $gitPath "\bin"), "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + $hgPath, "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + $scriptsPath, "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $toolsPath "\UnixUtils"), "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $utilsPath "\SysinternalsSuite"), "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $toolsPath "\fizzler"), "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $toolsPath "\Remote Desktop Connection Manager"), "Process")

# Go lang
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $rootDevPath "\go\bin"), "Process")
[System.Environment]::SetEnvironmentVariable("GOROOT", (Join-Path $rootDevPath "\go"), "Process")

# Python
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $rootDevPath "\python27"), "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $rootDevPath "\python27\scripts"), "Process")

# Ruby
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $rootDevPath "\Ruby193\bin"), "Process")

# Android
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $rootDevPath "\android-sdk\tools"), "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $rootDevPath "\android-sdk\platform-tools"), "Process")
[System.Environment]::SetEnvironmentVariable("ANDROID_NDK_PATH", (Join-Path $rootDevPath "\ndk\android-ndk-r8d"), "Process")
[System.Environment]::SetEnvironmentVariable("ANDROID_SDK_HOME", (Join-Path $rootDevPath "\android-sdk"), "Process")
[System.Environment]::SetEnvironmentVariable("ADT_HOME", (Join-Path $rootDevPath "\android-sdk"), "Process")

# Ant
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $rootDevPath "\apache-ant-1.9.4\bin"), "Process")
[System.Environment]::SetEnvironmentVariable("ANT_HOME", (Join-Path $rootDevPath "\apache-ant-1.9.4"), "Process")


## [System.Environment]::SetEnvironmentVariable("GIT_EXTERNAL_DIFF", ($toolsPath.Replace('\', '/') + '/KDiff3/kdiff3.exe'), "Process")

Set-Alias fiddler "$toolsPath\Fiddler2\fiddler.exe"
Set-Alias pgui "$toolsPath\PowerGUI\ScriptEditor.exe"
Set-Alias npp "$toolsPath\Notepad++\Notepad++.exe"
Set-Alias np2 "$toolsPath\notepad2.exe"
Set-Alias kdiff "$toolsPath\kDiff3\kdiff3.exe"
Set-Alias ilspy "$toolsPath\ILSpy\ilspy.exe"
Set-Alias lpad "$toolsPath\LINQPad\LINQPad.exe"
Set-Alias winm "$toolsPath\WinMerge\WinMergeU.exe"
Set-Alias g "git"
Set-Alias regexb "$toolsPath\RegexBuddy\RegexBuddy4.exe"
Set-Alias vim "$toolsPath\Vim\vim74\gvim.exe"
Set-Alias efh ExplorerFromHere
Set-Alias fsi "C:\Program Files (x86)\Microsoft SDKs\F#\3.1\Framework\v4.0\fsi.exe"
Set-Alias vs13 "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe"

function gs { invoke-command -scriptblock { git status } }
function ExplorerFromHere { explorer (Get-Location).Path }
function gsvn { invoke-command -scriptblock { git svn dcommit } }

# Fool git in to thinking it's in a TERM session.
$env:TERM = 'cygwin'
$env:LESS = 'FRSX'

$Global:maximumHistoryCount = 1024
$Global:CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$UserType = "User"
$CurrentUser.Groups | foreach {
    if ($_.value -eq "S-1-5-32-544") {
        $UserType = "Admin" }
    }

function prompt {

	 $Host.UI.RawUI.BackgroundColor = [System.ConsoleColor]::Black

     $Host.UI.RawUI.WindowTitle = "Role($UserType): " + $(Get-Location)

	 if ($UserType -ne "Admin") {
	 	$Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::DarkRed
	 } else {
	 	$Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::Green
	 }

	ImportModules
	GetAliasSuggestion #Display aliases for commands if they exist.

    $symbolicref = git symbolic-ref HEAD

    if($symbolicref -ne $NULL) {
		Write-Host (Get-Date -Format "HH:mm:ss") -ForegroundColor DarkYellow -NoNewline
        Write-Host " - git ["$symbolicref.substring($symbolicref.LastIndexOf("/") +1)"] "
    } else {
		Write-Host (Get-Date -Format "HH:mm:ss") -ForegroundColor DarkYellow
	}

	# No need to use the return keyword
	"[$env:username@$([System.Net.Dns]::GetHostName()) $(Get-Location)]$ "
 }

 # Calls Get-AliasSuggestion.ps1 in the tools directory.
 function GetAliasSuggestion {

	## Get the last item from the history

	$historyItem = Get-History -Count 1

	## If there were any history items
    if($historyItem)
    {
        ## Get the training suggestion for that item
        $suggestions = @(Get-AliasSuggestion $historyItem.CommandLine)

        ## If there were any suggestions
        if($suggestions)
        {
            ## For each suggestion, write it to the screen
            foreach($aliasSuggestion in $suggestions)
            {
                Write-Host "$aliasSuggestion"
            }
            Write-Host ""
        }
    }
 }

 function ImportModules() {

	if (-not (Get-Module Pscx)) {
		Write-Host "Importing Pscx module..." -NoNewline
		Import-Module Pscx | Out-Null
		Write-Host 'Done' -ForegroundColor Yellow
	}

	if (-not (Get-Module PowerTab)) {
		if (Test-Path "$env:userprofile\Documents\WindowsPowerShell\PowerTabConfig.xml") {
			 $null = Import-Module PowerTab -ArgumentList "$env:userprofile\Documents\WindowsPowerShell\PowerTabConfig.xml" | Out-Null
		} else {
			Import-Module PowerTab | Out-Null
		}
	}

	if (-not (Get-Module z)) {
		Write-Host "Importing z module..." -NoNewline
		Import-Module z
		Write-Host 'Done' -ForegroundColor Yellow
	}

	if (-not (Get-Module posh-git)) {
		Write-Host "Importing posh-git module..." -NoNewline
		Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)
		Import-Module posh-git
		Pop-Location
		Write-Host 'Done' -ForegroundColor Yellow
	}

    # PSReadLine Module
    if (-not (Get-Module PSReadLine)) {

	Write-Host "Importing PSReadLine module..." -NoNewline
        Import-Module PSReadline
        Write-Host 'Done' -ForegroundColor Yellow

        Write-Host # Leave a blank line once the last module has been imported.
    }
 }
