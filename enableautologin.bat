@echo off
color 1e
mode con: cols=31 lines=23
echo.
echo    ******             ******  
echo   ****                   **** 
echo  ***      ***********      ***
echo  **     ***************     **
echo  *    *******************    *
echo  *   ****             ****   *
echo      ***    *******    ***    
echo     ***    *********    ***   
echo     ***   ***     ***   ***   
echo     ***   **       **   ***   
echo     *Bright House Networks*   
echo     ***   **       **   ***   
echo     ***   ***     ***   ***   
echo     ***    ********     ***   
echo      ***    *******    ***    
echo  *   ****             ****   *
echo  *    *******************    *
echo  **     ***************     **
echo  ***      ***********      ***
echo  ****                    **** 
echo   ******              ******  
ping 127.0.0.1 -n 2 >nul

mode con: cols=141 lines=25
color 07

echo Created by Hofmannia Studios 2015
echo All rights reserved and other fake legal sounding stuff...
echo.
echo.
echo.
echo.
set MACHINENAME=%1
if "%MACHINENAME%"=="" (
	set /p MACHINENAME=Specify Remote Machine Name: 
) else (
	echo Connecting to %MACHINENAME%...
)

for /F "delims=" %%q in ('reg query "\\%MACHINENAME%\HKLM" 2^>^&1 ^| find "The network path was not found"') do (
	echo.
	echo.
	call :cecho 0c "The network path was not found. Make sure the computer is online and pingable."
	echo.
	echo.
	pause
	goto :eof
)

for /F "delims=" %%q in ('reg query "\\%MACHINENAME%\HKLM" 2^>^&1 ^| find "Access is denied"') do (
	echo.
	echo.
	call :cecho 0c "Access to the registry was denied. Make sure the computer is in the proper OU and update group policy."
	echo.
	echo.
	pause
	goto :eof
)

echo.
set /p AUTOLOGONNAME=Specify Username for Autologon: 
echo.
set /p AUTOLOGONPASSWORD=Specify Password for Autologon: 
echo.
set /p AUTOLOGONCOUNT=Specify Number of Times to Autologon: 
echo.

reg add "\\%MACHINENAME%\HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v AutoAdminLogon /t REG_SZ /d 1 >nul 2>&1
if %ERRORLEVEL%==0 (
	echo.
	call :cecho 0a "Setting HKLM-SOFTWARE-Microsoft-Windows NT-CurrentVersion-Winlogon-AutoAdminLogon to 1 Succeeded"
) else (
	echo.
	call :cecho 0c "Setting HKLM-SOFTWARE-Microsoft-Windows NT-CurrentVersion-Winlogon-AutoAdminLogon to 1 Failed"
)

reg add "\\%MACHINENAME%\HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v DefaultUserName /t REG_SZ /d %AUTOLOGONNAME% >nul 2>&1
if %ERRORLEVEL%==0 (
	echo.
	call :cecho 0a "Setting HKLM-SOFTWARE-Microsoft-Windows NT-CurrentVersion-Winlogon-DefaultUserName to %AUTOLOGONNAME% Succeeded"
) else (
	echo.
	call :cecho 0c "Setting HKLM-SOFTWARE-Microsoft-Windows NT-CurrentVersion-Winlogon-DefaultUserName to %AUTOLOGONNAME% Failed"
)

reg add "\\%MACHINENAME%\HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v DefaultPassword /t REG_SZ /d %AUTOLOGONPASSWORD% >nul 2>&1
if %ERRORLEVEL%==0 (
	echo.
	call :cecho 0a "Setting HKLM-SOFTWARE-Microsoft-Windows NT-CurrentVersion-Winlogon-DefaultPassword to %AUTOLOGONPASSWORD% Succeeded"
) else (
	echo.
	call :cecho 0c "Setting HKLM-SOFTWARE-Microsoft-Windows NT-CurrentVersion-Winlogon-DefaultPassword to %AUTOLOGONPASSWORD% Failed"
)

reg add "\\%MACHINENAME%\HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v AutoLogonCount /t REG_DWORD /d %AUTOLOGONCOUNT% >nul 2>&1
if %ERRORLEVEL%==0 (
	echo.
	call :cecho 0a "Setting HKLM-SOFTWARE-Microsoft-Windows NT-CurrentVersion-Winlogon-AutoLogonCount to %AUTOLOGONCOUNT% Succeeded"
) else (
	echo.
	call :cecho 0c "Setting HKLM-SOFTWARE-Microsoft-Windows NT-CurrentVersion-Winlogon-AutoLogonCount to %AUTOLOGONCOUNT% Failed"
)

reg query "\\%MACHINENAME%\HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticecaption >nul 2>&1
if %ERRORLEVEL%==0 (
	reg delete "\\%MACHINENAME%\HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /f /v legalnoticecaption >nul 2>&1
	if %ERRORLEVEL%==0 (
		echo.
		call :cecho 0a "Deletion of HKLM-SOFTWARE-Microsoft-Windows-CurrentVersion-Policies-System-legalnoticecaption Succeeded"
	) else (
		echo.
		call :cecho 0c "Deletion of HKLM-SOFTWARE-Microsoft-Windows-CurrentVersion-Policies-System-legalnoticecaption Failed"
	)
) else (
	echo.
	call :cecho 0c "HKLM-SOFTWARE-Microsoft-Windows-CurrentVersion-Policies-System-legalnoticecaption Does not exist"
)

reg query "\\%MACHINENAME%\HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticetext >nul 2>&1
if %ERRORLEVEL%==0 (
	reg delete "\\%MACHINENAME%\HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /f /v legalnoticetext >nul 2>&1
	if %ERRORLEVEL%==0 (
		echo.
		call :cecho 0a "Deletion of HKLM-SOFTWARE-Microsoft-Windows-CurrentVersion-Policies-System-legalnoticetext Succeeded"
	) else (
		echo.
		call :cecho 0c "Deletion of HKLM-SOFTWARE-Microsoft-Windows-CurrentVersion-Policies-System-legalnoticetext Failed"
	)
) else (
	echo.
	call :cecho 0c "HKLM-SOFTWARE-Microsoft-Windows-CurrentVersion-Policies-System-legalnoticetext Does not exist"
)

reg add "\\%MACHINENAME%\HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /f /v DisableAutoLogon /t REG_SZ /d \\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat >nul 2>&1
if %ERRORLEVEL%==0 (
	echo.
	call :cecho 0a "Setting HKLM-SOFTWARE-Microsoft-Windows-CurrentVersion-RunOnce-DisableAutoLogon to DisableAutoLogon.bat Succeeded"
) else (
	echo.
	call :cecho 0c "Setting HKLM-SOFTWARE-Microsoft-Windows-CurrentVersion-RunOnce-DisableAutoLogon to DisableAutoLogon.bat Failed"
)

echo @echo off >\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo setlocal ENABLEDELAYEDEXPANSION  >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo set counter=%AUTOLOGONCOUNT% >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo call :countdown >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo if %%counter%% LEQ 1 ( >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v AutoAdminLogon >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v DefaultUserName >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v DefaultPassword >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /f /v AutoLogonCount >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	gpupdate /force /boot >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	echo @echo off ^>%%temp%%\DeleteDisableAutoLogon.bat >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	echo ping 127.0.0.1 ^^^>nul ^>^>%%temp%%\DeleteDisableAutoLogon.bat >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	echo del /f %%public%%\desktop\DisableAutoLogon.bat ^>^>%%temp%%\DeleteDisableAutoLogon.bat >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	echo exit ^>^>%%temp%%\DeleteDisableAutoLogon.bat >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	start %%temp%%\DeleteDisableAutoLogon.bat >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo ) else ( >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /f /v DisableAutoLogon /t REG_SZ /d \\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	reg delete "\\%MACHINENAME%\HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /f /v legalnoticecaption >nul 2>&1 >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	reg delete "\\%MACHINENAME%\HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /f /v legalnoticetext >nul 2>&1 >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	set /a counter=%%counter%%-1  >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo 	echo set counter=^!counter^!  ^>^>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo )  >>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat
echo :countdown>>\\%MACHINENAME%\c$\Users\Public\Desktop\DisableAutoLogon.bat


pause
goto :eof

:cecho <color> <string> </nb>

@rem Created by Hofmannia Studios 2015
@rem All rights reserved and other fake legal sounding stuff...

@echo off

rem Setting variables.
set colvar=%~1
set stringvar=%~2

rem Help functionality.
if "%~1"=="/?" (
call :helptext
set ERRORLEVEL=0
goto :eof
)

rem Start defining cecho errors.
if not defined %colvar (
call :colorerror
set ERRORLEVEL=1
goto :eof
)

if not "%colvar%"=="%colvar:~0,2%" (
call :colorerror
set ERRORLEVEL=1
goto :eof
)

if "%colvar:~1,1%"=="" (
call :colorerror
set ERRORLEVEL=1
goto :eof
)

if "%colvar%" NEQ "/?" if not defined stringvar (
call :stringerror
set ERRORLEVEL=1
goto :eof
)
rem End defining cecho errors.

rem Find length of this file's name.
setlocal enableDelayedExpansion

(
	set "s=%~nx0#"
	set "len=0"
	for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
		if "!s:~%%P,1!" NEQ "" ( 
		set /a "len+=%%P"
		set "s=!s:~%%P!"
        	)
	)
)
(
endlocal
set "namelength=%len%"
)

set /a namelength=%namelength%+6

rem Create a variable containing a backspace character.
for /F "tokens=1 delims=#" %%a in ('"prompt #$H# & echo on & for %%b in (1) do rem"') do set "delchar=%%a"

rem Use findstr to search this file and nul and display lines consisting of "-" with our string and "\..\" appended at the start of the output. All output will be colored based on our color code.
pushd %~dp0
findstr /p /r /a:%~1 "^-" "%~2\..\%~nx0" nul
popd

rem Delete the name of this file, "\..\", and ":-" from the output.
for /l %%n in (1,1,%namelength%) do <nul set /p "=%delchar%"

endlocal

rem Add a line break if nb switch was not used.
if not "%~3"=="/nb" echo.

goto :eof

:colorerror
echo color must be in 2 digit hex format!
goto :eof

:stringerror
echo string is required!
goto :eof

:helptext
echo Usage: Displays text in a specified color.
echo.
echo cecho color string [/nb]
echo.
echo   color		Specifies color attribute with two hex digits. See "color /?"
echo.
echo   string	The text to be displayed. Text containing spaces must be placed
echo   		within quotation marks.
echo.
echo   [/nb]		Optional. Removes the line break after the text. The next
echo			command will display on the same line.
echo.
echo    Example:
echo.
echo cecho 0b Hello
echo.
echo    Would display the text "Hello" with a black background
echo    and light aqua font and then proceed to the next line.
echo.
call :cecho 0b "   Hello"
echo.
echo cecho 20 "This is" /nb ^& cecho 02 "a test" /nb ^& cecho 20 "of cecho"
echo.
echo    Would display the text "This is a test of cecho" on one line with
echo    "This is" and "of cecho" in black text on a green background, and
echo    "a test" in green text on a black background, then proceed to the
echo    next line.
echo.
call :cecho 00 "   " /nb & call :cecho 20 "This is" /nb & call :cecho 02 "a test" /nb & call :cecho 20 "of cecho"
echo.
echo.
pause
goto :eof
rem The last line of this file must consist of simply "-"!
-