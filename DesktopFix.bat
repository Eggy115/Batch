@echo off
setlocal enabledelayedexpansion
Set /p MACHINENAME=Enter remote machine name: 
Set /p USERNAME=Enter username of affected user: 
echo Searching for correct SID...
for /f "tokens=7 delims=\" %%i in ('reg query "\\%MACHINENAME%\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" /f "*-*-*-*-*-*-*-*"') do (
	reg query "\\%MACHINENAME%\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\%%i" /v ProfileImagePath | findstr /i %USERNAME%
	rem echo !ERRORLEVEL!
	if !ERRORLEVEL!==0 (
		Set USERSID=%%i
		goto APPLYFIX
	)
)
Echo Username not found under any SID!
pause
exit
:APPLYFIX
reg add "\\%MACHINENAME%\HKEY_USERS\%USERSID%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop /t REG_EXPAND_SZ /d %%USERPROFILE%%\Desktop /f
pause