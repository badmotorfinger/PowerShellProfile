##############################################################################
##
## Vince Panuccio's custom PowerShell prompt.
##
##############################################################################

Set-Alias npp "C:\Program Files\Notepad++\notepad++.exe"
Set-Alias kdiff "C:\Program Files\KDiff3\kdiff3.exe"
Set-Alias lpad "C:\Program Files (x86)\LINQPad5\LINQPad.exe"
Set-Alias winm "C:\Program Files (x86)\WinMerge\WinMergeU.exe"
Set-Alias regexb "$Env:TOOLS\RegexBuddy\RegexBuddy4.exe"
Set-Alias vim "C:\tools\vim\vim82\gvim.exe"
Set-Alias mc "C:\Program Files (x86)\Midnight Commander\mc.exe"
Set-Alias rdcman "C:\Program Files (x86)\Microsoft\Remote Desktop Connection Manager\RDCMan.exe"

Set-Alias g "git"
Set-Alias efh ExplorerFromHere

function gs { invoke-command -scriptblock { git status } }
function glog { invoke-command -scriptblock { git log --name-status } }
function glogs { invoke-command -scriptblock { git log -p } }
function glogk { invoke-command -scriptblock { git log --all --graph --decorate --oneline --simplify-by-decoration } }
function gbranch-recent { invoke-command -scriptblock { git log --all --graph --decorate --oneline --simplify-by-decoration } }
function lg1 {git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all }
function lg2 {git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all }
function ExplorerFromHere { explorer (Get-Location).Path }

# Set the default fzf command
$env:FZF_DEFAULT_COMMAND='cmd /c dir /s/b'

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
  #"[$env:username@$([System.Net.Dns]::GetHostName()) $(Get-Location)]$ "
  "$(Get-Location)> "
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


$vsPath = 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools';
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
  Write-Host "Visual Studio 2019 Command Prompt variables set." -ForegroundColor Magenta
} else {
    Write-Host "Visual Studio 2019 not found" -ForegroundColor Red
}

Write-Host # Leave a blank line once the last module has been imported.
