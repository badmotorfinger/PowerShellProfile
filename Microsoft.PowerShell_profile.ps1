##############################################################################
##
## Vince Panuccio's custom PowerShell prompt.
##
##############################################################################

$toolsPath = "%toolspath%"
$utilsPath = "%utilspath%"
$gitPath = "$toolsPath\git"
$scriptsPath = "$toolsPath\psscripts"

[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + $toolsPath, "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $gitPath "\bin"), "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + $scriptsPath, "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $toolsPath "\UnixUtils"), "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $utilsPath "\SysinternalsSuite"), "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $toolsPath "\fizzler"), "Process")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + (Join-Path $toolsPath "\Remote Desktop Connection Manager"), "Process")

## [System.Environment]::SetEnvironmentVariable("GIT_EXTERNAL_DIFF", ($toolsPath.Replace('\', '/') + '/KDiff3/kdiff3.exe'), "Process")

Set-Alias fiddler "$toolsPath\Fiddler2\fiddler.exe"
Set-Alias pgui "$toolsPath\PowerGUI\ScriptEditor.exe"
Set-Alias npp "$toolsPath\Notepad++\Notepad++.exe"
Set-Alias np2 "$toolsPath\notepad2.exe"
Set-Alias kdiff "$toolsPath\kDiff3\kdiff3.exe"
Set-Alias ilspy "$toolsPath\ILSpy\ilspy.exe"
Set-Alias lpad "$toolsPath\LINQPad\LINQPad.exe"
Set-Alias winm "$toolsPath\WinMerge\WinMergeU.exe"

## Will get the last assembly compiled by linqpad and run JustDecompile to disassemble it.
Set-Alias lpadec "gci ""$env:TEMP\linqpad"" -Directory | Sort-Object LastWriteTime -Descending | select -First 1 | gci -filter *.dll | Sort-Object LastWriteTime -Descending | select -First 1 | % { & ""c:\Program Files (x86)\Telerik\JustDecompile\Libraries\JustDecompile.exe"" $_.FullName }"

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
	GetAliasSuggestion

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
		Write-Host "Importing modules..." -NoNewline
		Import-Module Pscx
	}
	
	if (-not (Get-Module PowerTab)) {
		
		if (Test-Path "$env:userprofile\Documents\WindowsPowerShell\PowerTabConfig.xml") {
			Import-Module PowerTab -ArgumentList "$env:userprofile\Documents\WindowsPowerShell\PowerTabConfig.xml"
		} else {
			Import-Module PowerTab
		}
		
		Write-Host "Done."
	}	
 }
