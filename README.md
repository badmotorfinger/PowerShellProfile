# PowerShell_profile
My default PowerShell profile setup

Repo should be placed in `%USERPROFILE%\PowerShell_profile` so that `.gitignore` and other config files can by symlinked and kept in source control.

Then create a junction so that the repo lives with all the other source code `junction.exe D:\gitrepos\PowerShell_profiles .\PowerShell_profile\`

git configs
===========

`cmd /c mklink /H .gitignore .\PowerShell_profile\home-config\.gitignore`

`cmd /c mklink /H .gitconfig .\PowerShell_profile\home-config\.gitconifg`

`cmd /c mklink /H .\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 .\PowerShell_profile\Microsoft.PowerShell_profile.ps1`
