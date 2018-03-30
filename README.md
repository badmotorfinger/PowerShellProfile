# PowerShell_profile
My default PowerShell profile setup

Repo should be placed in `%USERPROFILE%\source\github\PowerShell_profile` so that `.gitignore` and other config files can by symlinked and kept in source control.

git configs
===========

` cmd /c mklink /H .gitignore .\source\github\PowerShell_profile\config\.gitignore`

`cmd /c mklink /H .gitconfig .\source\github\PowerShell_profile\config\.gitconfig`

`cmd /c mklink /H .\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 .\Source\github\PowerShell_profile\Microsoft.PowerShell_profile.ps1`
