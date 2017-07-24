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
Set-Alias lpad "$Env:TOOLS\LINQPad5\LINQPad.exe"
Set-Alias lpadmta "$Env:TOOLS\LINQPad5\LINQPad.exe -mta"
Set-Alias lp32 "$Env:TOOLS\LINQPad5-x86\LINQPad.exe"
Set-Alias lp32mta "$Env:TOOLS\LINQPad5-x86\LINQPad.exe -mta"

Set-Alias winm "C:\Program Files (x86)\WinMerge\WinMergeU.exe"
Set-Alias g "git"
Set-Alias regexb "$Env:TOOLS\RegexBuddy\RegexBuddy4.exe"
Set-Alias vim "c:\Program Files (x86)\Vim\vim80\gvim.exe"
Set-Alias vim "c:\Program Files (x86)\Vim\vim80\gvim.exe"
Set-Alias mc E:\CloudStation\tools\MidnightCommander\mc.exe
Set-Alias efh ExplorerFromHere

function gs { invoke-command -scriptblock { git status } }
function glog { invoke-command -scriptblock { git log --name-status } }
function glogs { invoke-command -scriptblock { git log -p } }
function glogk { invoke-command -scriptblock { git log --all --graph --decorate --oneline --simplify-by-decoration } }
function gbranch-recent { invoke-command -scriptblock { git log --all --graph --decorate --oneline --simplify-by-decoration } }
function lg1 {git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all }
function lg2 {git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all }
function ExplorerFromHere { explorer (Get-Location).Path }

# Fool git in to thinking it's in a TERM session.
$env:TERM = 'cygwin'
$env:LESS = 'FRSX'

# Remove default PowerShell alias for curl. We'll use the real curl!
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

	# No need to use the return keyword
  "[$env:username@$([System.Net.Dns]::GetHostName()) $(Get-Location)]$ "
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Write-Host "Importing git-psradar..." -NoNewline
Import-Module Git-PsRadar
Write-Host 'Done' -ForegroundColor Yellow

Write-Host "Importing z module..." -NoNewline
Import-Module z
Write-Host 'Done' -ForegroundColor Yellow

Write-Host "Importing posh-git module..." -NoNewline
Import-Module posh-git
Write-Host 'Done' -ForegroundColor Yellow

Write-Host "Importing Pscx module..." -NoNewline
Import-Module Pscx | Out-Null
Write-Host 'Done' -ForegroundColor Yellow

Write-Host "Importing PSReadLine module..." -NoNewline
Import-Module PSReadline
Write-Host 'Done' -ForegroundColor Yellow

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
  Write-Host "Visual Studio 2017 Command Prompt variables set." -ForegroundColor Magenta
} else {
    Write-Host "Visual Studio 2017 not found" -ForegroundColor Red
}

Write-Host # Leave a blank line once the last module has been imported.
