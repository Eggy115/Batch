:runasadmin
@echo off
cls

:checkforadminrights
if "%1"=="elevate" (
	shift
	goto :haverights
)

net file >nul 2>&1
if %errorlevel%==0 (
	goto :haverights
) else (
goto :getrights
)

:getrights
echo set uac = createobject("shell.application") > %temp%\getrights.vbs
echo uac.shellexecute "%~0",elevate,,"runas" >> "%temp%\getrights.vbs"
"%temp%\getrights.vbs"
exit

:haverights
@echo on
:runasadmin

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
ping 127.0.0.1 >nul
color 07
mode con: cols=79 lines=13

set retry=0
color 0c
echo ******************************************************************************
echo ******************************************************************************
echo ******************************************************************************
echo ******************************************************************************
echo ******************************************************************************
echo * Ensure that the flash drive that you want to make bootable is the only USB *
echo ********************* drive plugged into your computer!! *********************
echo ******************************************************************************
echo ******************************************************************************
echo ******************************************************************************
echo ******************************************************************************
echo ******************************************************************************
pause
mode con: cols=150 lines=25

:existingdrives
setlocal ENABLEDELAYEDEXPANSION
set letter=abfghijklmnopqrstuvwxyz

for /l %%d in (1,1,23) do (
	set dletter=!letter:~0,1!
	set letter=!letter:~1,23!
	if not exist !dletter!: (
		goto :drivescan
	)
)
setlocal disabledelayedexpansion
Echo No drives to use!
goto :eof

:drivescan
cls
color 07
echo.
echo.
echo Scanning disk drives...
setlocal enabledelayedexpansion
for /F "tokens=2 delims=PHYSICALDRIVE" %%s in ('wmic diskdrive get deviceid ^| find "PHYSICALDRIVE"') do (
	set drive=%%s
	echo select disk !drive! >%temp%\diskscript.txt
	echo detail disk >>%temp%\diskscript.txt
	for /F "tokens=2 delims=:" %%t in ('diskpart /s %temp%\diskscript.txt ^| find "USB" /i') do (
		set type=%%t
		if !type! == ^ USB goto :USB
	)
)

echo.
echo.
setlocal disabledelayedexpansion
call :cecho 0c "No USB drives detected! Please make sure your USB drive is plugged in and works."
pause
if %retry% == 3 goto:eof
set /a retry=%retry%+1
goto :drivescan

:USB
for /F "tokens=1 delims=:" %%n in ('diskpart /s %temp%\diskscript.txt ^| find "USB Device" /i') do (
	set diskname=%%n
)
echo.
echo.
call :cecho 0c "All data on %diskname% will be erased" /nb
setlocal disabledelayedexpansion
call :cecho 0c "! Are you sure you want to proceed? [Y,N]"
setlocal enabledelayedexpansion
set bootablefiles=\\tamp20pvfiler09\share1\installs\Division IT USB Imaging\Combined
set /p confirmation=
If /i %confirmation%==y (
	echo.
	echo.
	echo By default the bootable files will be copied from^:
	echo %bootablefiles%
	echo.
	echo This process can take some time. You can specify a local folder to copy the
	echo files from if you wish.
	echo.
	echo Do you have the bootable files stored locally? [Y,N]
	set /p local=
		if /i !local!==y (
		echo.
		echo.
		echo Path to local files ^(do not use quotes^)
		set /p bootablefiles=
	) 
	echo.
	echo.
	echo Creating bootable flash drive...
	echo select disk %drive% >%temp%\diskscript.txt
	echo clean >>%temp%\diskscript.txt
	echo create partition primary >>%temp%\diskscript.txt
	echo format fs=ntfs quick >>%temp%\diskscript.txt
	echo active >>%temp%\diskscript.txt
	echo assign letter=%dletter% >>%temp%\diskscript.txt
	diskpart /s %temp%\diskscript.txt
	ping 127.0.0.1 >nul
	robocopy "!bootablefiles!" %dletter%:\ * /e /z /is /v /nc
	ping 127.0.0.1 >nul
	echo.
	echo.
	setlocal disabledelayedexpansion
	echo.
	echo.
	call :cecho 0a "Bootable flash drive creation complete!"
	echo.
	echo.
) else (
	goto :eof
)
pause
exit

:cecho <color> <string> </nb>

@rem Created by Hofmannia Studios 2015
@rem All rights reserved and other fake legal sounding stuff...

rem @echo off

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