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

mode con: cols=80 lines=25
color 07

echo.
echo.
echo.
echo.

set MACHINENAME=%1

if NOT DEFINED MACHINENAME (
	set /p MACHINENAME=Specify Remote Machine Name: 
)

TITLE %MACHINENAME%

for /F "delims=" %%q in ('reg query "\\%MACHINENAME%\HKLM" 2^>^&1 ^| find "The network path was not found"') do (
	echo.
	echo.
	call :cecho 0c "The network path was not found. Make sure that the computer is online and       pingable."
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

reg add "\\%MACHINENAME%\HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v AllowRemoteRPC /t REG_DWORD /d 1 /f >nul 2>&1

if %ERRORLEVEL%==0 (
	echo.
	echo.
	call :cecho 0a "Enabling RemoteRPC Succeeded"
) else (
	echo.
	echo.
	call :cecho 0c "Enabling RemoteRPC Failed. Make sure " /nb
	call :cecho 0c %MACHINENAME% /nb
	call :cecho 0c " is online and reachable and try again." /nb
	ping 127.0.0.1 -n 10 >nul 2>&1
	exit
)
echo. 
echo. 
query session /server:%MACHINENAME%
echo.
echo.
REM reg add "\\%MACHINENAME%\HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v AllowRemoteRPC /t REG_DWORD /d 0 /f >nul 2>&1

REM if %ERRORLEVEL%==0 (
	REM echo.
	REM echo.
	REM call :cecho 0a "Disabling RemoteRPC Succeeded"
	echo.
	echo.
	echo Press any key when done.
	pause >nul 2>&1
	exit
REM ) else (
	REM echo.
	REM echo.
	REM call :cecho 0c "Disabling RemoteRPC Failed. Please make sure to manually disable RemoteRPC."
	REM pause
REM )
goto:eof

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