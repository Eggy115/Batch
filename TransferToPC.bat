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
echo.
echo Moving files...
md C:\maps
md C:\BHN_TPA_Fiber_Map_System_PROVIEWER


:Win7
echo Moving files...
xcopy %~dp0%username%\Favorites\*.* %USERPROFILE%\Favorites  /E /I /C /Y /Z
echo.
xcopy %~dp0%username%\Desktop\*.* %USERPROFILE%\Desktop  /E /I /C /Y /Z
echo.
xcopy %~dp0%username%\MyPictures\*.* %USERPROFILE%\Pictures  /E /I /C /Y /Z
echo.
xcopy %~dp0%username%\MyDocuments\*.* %USERPROFILE%\Documents  /E /I /C /Y /Z
echo.
xcopy %~dp0%username%\Music\*.* %USERPROFILE%\Music  /E /I /C /Y /Z
echo.
xcopy %~dp0%username%\Videos\*.* %USERPROFILE%\Videos  /E /I /C /Y /Z
echo.
if exist %USERPROFILE%\AppData\Local\Google\Chrome xcopy %~dp0%username%\Chrome\*.* "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\"   /E /I /C /Y /Z
echo.
if exist %~dp0%username%\Outlook\*.pst xcopy %~dp0%username%\Outlook\*.* %USERPROFILE%\AppData\Local\Microsoft\Outlook  /E /I /C /Y /Z
echo.
xcopy %~dp0%username%\xcor\*.* C:\ProgramData\Xcor /E /I /C /Y /Z
echo.
xcopy %~dp0%username%\maps\*.* C:\maps /E /I /C /Y /Z
echo.
xcopy %~dp0BHN_TPA_Fiber_Map_System_PROVIEWER\*.* C:\BHN_TPA_Fiber_Map_System_PROVIEWER\ /E /I /C /Y /Z
echo.

goto cleanup 

:Cleanup

:: Removing the %username% filed is REM'd out in case a retry is needed.
:: Remove the \%username% folder to avoid H:\ clutter
del /f /s /q %~dp0%username% >nul
rd %~dp0%username% /s /q
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
echo %~dp%username% folder is missing.  Cannot continue.
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
