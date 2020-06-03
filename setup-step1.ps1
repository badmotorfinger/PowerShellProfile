#Run this script on a fresh install of Windows
cls

$currentDir = Split-Path $MyInvocation.MyCommand.Definition

Write-Host "Current directory is $currentDir"


Write-Host 'Installing Chocolatey & packages...' -ForegroundColor Green
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

choco install git --limit-output -y
choco install nodejs --limit-output -y
choco install sysinternals --limit-output -y
choco install winmerge --limit-output -y
choco install rdcman --limit-output -y
choco install notepadplusplus --limit-output -y
choco install curl --limit-output -y
choco install everything --limit-output -y
choco install kdiff3 --limit-output -y
choco install linqpad --limit-output -y
choco install winmerge --limit-output -y
choco install conemu --limit-output -y
choco install 7zip.install --limit-output -y
choco install greenshot --limit-output -y
choco install sumatrapdf --limit-output -y
choco install paint.net --limit-output -y
choco install filezilla --limit-output -y
choco install unxutils --limit-output -y

Write-Host 'Installing Scoop & packages...' -ForegroundColor Green
Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')

scoop install dnspy

pause
exit
