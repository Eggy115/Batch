:: Windows user file transfer utility with exclusions. (Part 2) 
:: This file is copied in by the script "TransferToH.bat"
:: The %USERPROFILE% variable is very cool and eliminates creating a new "My Pictures" 
:: or "My [whatever]" file when moving the files from H:\ (XCOPY glitch)
:: This transfer utility (in 2 parts) can be used to transfer user files from XP or Win 7 to XP or Win 7 (universal) ::

:: XCOPY switches I use here:
:: /E Copies directories and subdirectories, including empty ones.
:: /I If destination does not exist and copying more than one file, assumes that destination must be a directory.
:: /C Continues copying even if errors occur.
:: /Y Suppresses prompting to confirm you want to overwrite an existing destination file.
:: /Z Resumes the copy operation after a network error (if one occurs)

@echo off
:: Ensure the files to be moved are there, and abort if missing.
if not exist %~dp0\transferred goto nosource
:: Check version and jump to appropriate section (I only care about XP or Win7 )::
:: VER | FINDSTR /IL "5.1." > NUL
:: IF %ERRORLEVEL% EQU 0 SET WinVersion=XP

:: VER | FINDSTR /IL "6.1." > NUL
:: IF %ERRORLEVEL% EQU 0 SET WinVersion=Win7

:: If the version is not Windows 7 or XP, let me know and then quit ::
:: if not %ERRORLEVEL% EQU 0 goto Aborted

@echo off
echo input username
set /p input=""
cls


if exist C:\"Program Files (x86)" goto Win7
:: goto %winversion%

:XP
xcopy %~dp0Transferred\Favorites\*.* C:\"Documents and Settings"\%input%\Favorites /E /I /C /Y /Z
echo.
xcopy %~dp0Transferred\Desktop\*.* C:\"Documents and Settings"\%input%\Desktop /E /I /C /Y /Z
echo.
xcopy %~dp0Transferred\MyDocuments\*.* C:\"Documents and Settings"\%input%\"My Documents"  /E /I /C /Y /Z
echo.
xcopy %~dp0Transferred\MyPictures\*.* C:\"Documents and Settings"\%input%\"My Documents"\"My Pictures" /E /I /C /Y /Z
echo.
xcopy %~dp0Transferred\Music\*.* C:\"Documents and Settings"\%input%\"My Music"\"My Pictures" /E /I /C /Y /Z
echo.
xcopy %~dp0Transferred\Videos\*.* C:\"Documents and Settings"\%input%\"My Documents"\"My Videos" /E /I /C /Y /Z
echo.
xcopy %~dp0Transferred\Chrome\*.* "C:\Documents and Settings\%input%\Application Data\Local\Chrome\User Data" /E /I /C /Y /Z
echo.
xcopy %~dp0Transferred\Outlook\*.* "C:\Documents and Settings\%input%\Application Data\Local\Microsoft\Outlook\" /E /I /C /Y /Z
echo.

:: NEED XP .PST file location here
goto Cleanup

:Win7
echo Moving files...
xcopy %~dp0Transferred\Favorites\*.* C:\Users\%input%\Favorites  /E /I /C /Y /Z
echo.
xcopy %~dp0Transferred\Desktop\*.* C:\Users\%input%\Desktop  /E /I /C /Y /Z
echo.
xcopy %~dpTransferred\MyPictures\*.* C:\Users\%input%\Pictures  /E /I /C /Y /Z
:: if errorlevel==0 del %~dp0\Transferred\MyDocuments\MyPictures /Q
echo.
xcopy %~dp0Transferred\MyDocuments\*.* C:\Users\%input%\Documents  /E /I /C /Y /Z
echo.
xcopy %~dp0Transferred\Music\*.* C:\Users\%input%\Music  /E /I /C /Y /Z
echo.
xcopy %~dp0Transferred\Videos\*.* C:\Users\%input%\Videos  /E /I /C /Y /Z
echo.
if exist %USERPROFILE%\AppData\Local\Google\Chrome xcopy %~dp0Transferred\Chrome\*.* "C:\Users\%input%\AppData\Local\Google\Chrome\User Data\"   /E /I /C /Y /Z
echo.
if exist %~dp0\Transferred\Outlook\*.pst xcopy %~dp0Transferred\Outlook\*.* C:\Users\%input%\AppData\Local\Microsoft\Outlook  /E /I /C /Y /Z

goto cleanup 

:Cleanup

:: Removing the transferred filed is REM'd out in case a retry is needed.
:: Remove the \Transferred folder to avoid H:\ clutter
rem rd %~dp0\Transferred /S /Q 
:: Then cleanup the other file used to make the transfer
rem del %~dp0\TransferFromH.bat /Q
:: Deleting this script teminates its execution immediately
goto end

:Aborted
echo.
echo This version of Windows is not recognized, or the query failed.
echo Move the files manually
echo.
echo Press any key to exit...
pause>nul


:nosource
echo.
echo %~dpTransferred folder is missing.  Cannot continue.
echo.
echo Press any key to exit...
pause>nul

:end
echo.
echo Transfer complete.
echo.
echo Press any key to exit...
pause>nul
exit
