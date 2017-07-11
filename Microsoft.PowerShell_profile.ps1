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
Set-Alias lp "$Env:TOOLS\LINQPad5\LINQPad.exe"
Set-Alias lpmta "$Env:TOOLS\LINQPad5\LINQPad.exe -mta"
Set-Alias lp32 "$Env:TOOLS\LINQPad5-x86\LINQPad.exe"
Set-Alias lp32mta "$Env:TOOLS\LINQPad5-x86\LINQPad.exe -mta"

Set-Alias winm "$Env:TOOLS\WinMerge\WinMergeU.exe"
Set-Alias g "git"
Set-Alias regexb "$Env:TOOLS\RegexBuddy\RegexBuddy4.exe"
Set-Alias vim "c:\Program Files\Vim\vim80\gvim.exe"
Set-Alias efh ExplorerFromHere

function gs { invoke-command -scriptblock { git status } }
function glog { invoke-command -scriptblock { git log --name-status } }
function glogs { invoke-command -scriptblock { git log -p } }
function glogk { invoke-command -scriptblock { git log --all --graph --decorate --oneline --simplify-by-decoration } }
function gbranch-recent { invoke-command -scriptblock { git log --all --graph --decorate --oneline --simplify-by-decoration } }
function lg1 {git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all }
function lg2 {git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all }
function gsvn { invoke-command -scriptblock { git svn dcommit } } # git svn commit alias
function ExplorerFromHere { explorer (Get-Location).Path }
function gsvn { invoke-command -scriptblock { git svn dcommit } }

# Fool git in to thinking it's in a TERM session.
$env:TERM = 'cygwin'
$env:LESS = 'FRSX'

# Remove default PowerShell alias
Remove-Item alias:curl

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
	
	# No need to use the return keyword
  	"[$env:username@$([System.Net.Dns]::GetHostName()) $(Get-Location)]$ "
 }

 function ImportModules() {

    if ($global:mod_loaded -eq $null) {

        $vsPath = 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\Tools';
        if ((Test-Path $vsPath))
        {
          pushd $vsPath
          cmd /c "VsDevCmd.bat&set" |
          foreach {
            if ($_ -match "=") {
              $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
            }
          }
          popd
          write-host "Visual Studio 2017 Command Prompt variables set." -ForegroundColor Magenta
        } else {
            Write-Host "Visual Studio 2017 not found" -ForegroundColor Red
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
