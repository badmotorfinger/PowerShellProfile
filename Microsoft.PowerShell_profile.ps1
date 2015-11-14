##############################################################################
##
## Vince Panuccio's custom PowerShell prompt.
##
##############################################################################

Set-Alias fiddler "$Env:TOOLS\Fiddler2\fiddler.exe"
Set-Alias pgui "$Env:TOOLS\PowerGUI\ScriptEditor.exe"
Set-Alias npp "$Env:TOOLS\Notepad++\Notepad++.exe"
Set-Alias np2 "$Env:TOOLS\notepad2.exe"
Set-Alias kdiff "$Env:TOOLS\kDiff3\kdiff3.exe"
Set-Alias ilspy "$Env:TOOLS\ILSpy\ilspy.exe"
Set-Alias lp4 "$Env:TOOLS\LINQPad4\LINQPad.exe"
Set-Alias lp5 "$Env:TOOLS\LINQPad5\LINQPad.exe"
Set-Alias winm "$Env:TOOLS\WinMerge\WinMergeU.exe"
Set-Alias g "git"
Set-Alias regexb "$Env:TOOLS\RegexBuddy\RegexBuddy4.exe"
Set-Alias vim "$Env:TOOLS\Vim\vim74\gvim.exe"
Set-Alias efh ExplorerFromHere
Set-Alias vs13 "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe"

function gs { invoke-command -scriptblock { git status } }
function gsvn { invoke-command -scriptblock { git svn dcommit } } # git svn commit alias
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

    if ($global:mod_loaded -eq $null) {

        $vsPath = 'C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC';
        if ((Test-Path $vsPath))
        {
          pushd $vsPath
          cmd /c "vcvarsall.bat&set" |
          foreach {
            if ($_ -match "=") {
              $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
            }
          }
          popd
          write-host "Visual Studio 2015 Command Prompt variables set." -ForegroundColor Magenta
        } else {
            Write-Host "Visual Studio 2015 not found" -ForegroundColor Red
        }

        if (-not (Get-Module Pscx)) {
            Write-Host "Importing Pscx module..." -NoNewline
            Import-Module Pscx | Out-Null
            Write-Host 'Done' -ForegroundColor Yellow
        }

        #if (-not (Get-Module PowerTab)) {
        #    if (Test-Path "$env:userprofile\Documents\WindowsPowerShell\PowerTabConfig.xml") {
        #        $null = Import-Module PowerTab -ArgumentList "$env:userprofile\Documents\WindowsPowerShell\PowerTabConfig.xml" | Out-Null
        #    } else {
        #        Import-Module PowerTab | Out-Null
        #    }
        #}

        if (-not (Get-Module Git-PsRadar)) {
            Write-Host "Importing git-psradar..." -NoNewline
            Import-Module Git-PsRadar
            Write-Host 'Done' -ForegroundColor Yellow
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

        $global:mod_loaded = 'loaded'
    }
 }
