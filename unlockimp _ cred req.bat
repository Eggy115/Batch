@echo off 
powershell.exe -Command "& {Import-Module ActiveDirectory; Read-Host "Enter the user account to unlock" | Unlock-ADAccount -Credential $(Get-Credential)}"
pause