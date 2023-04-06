SETLOCAL
@echo off
set VERSION=2.8b
%SystemDrive% && cls
title [TEMP FILE CLEANUP v%VERSION%]
 
:::::::::::::::
:: VARIABLES ::
:::::::::::::::
:: Set your paths here. !! Don't use trailing slashes (\) in directory paths
set LOGPATH=%SystemDrive%\Logs
set LOGFILENAME=%COMPUTERNAME%_TempFileCleanup.log
:: Max log file size allowed in bytes before rotation and archive. 1048576 bytes is one megabyte
set LOG_MAX_SIZE=2097152
 
:: \/ Don't touch these variables. If you do, you will break something.
set CUR_DATE=%DATE:~-4%-%DATE:~4,2%-%DATE:~7,2%
set IS_SERVER_OS=no
 
 
:::::::::::::::::::::::
:: LOG FILE HANDLING ::
:::::::::::::::::::::::
:: Make the logfile if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%
if not exist %LOGPATH%\%LOGFILENAME% echo. > %LOGPATH%\%LOGFILENAME%
 
:: Check log size. If it's less than our max, then jump to the cleanup section
for %%R in (%LOGPATH%\%LOGFILENAME%) do IF %%~zR LSS %LOG_MAX_SIZE% goto os_version_detection
 
:: If the log was too big, go ahead and rotate it.
pushd %LOGPATH%
del %LOGFILENAME%.ancient 2>NUL
rename %LOGFILENAME%.oldest %LOGFILENAME%.ancient 2>NUL
rename %LOGFILENAME%.older %LOGFILENAME%.oldest 2>NUL
rename %LOGFILENAME%.old %LOGFILENAME%.older 2>NUL
rename %LOGFILENAME% %LOGFILENAME%.old 2>NUL
popd
 
 
::::::::::::::::::::::::::
:: OS VERSION DETECTION ::
::::::::::::::::::::::::::
:os_version_detection
:: Check Windows version. If it's a Server OS set the variable "IS_SERVER_OS" to yes. This affects what we do later.
wmic os get name | findstr "Server" > nul
IF %ERRORLEVEL%==0 set IS_SERVER_OS=yes
 
 
::::::::::::::::::::::::::
:: USER CLEANUP SECTION :: -- Most stuff in here doesn't require Admin rights
::::::::::::::::::::::::::
:: Create the log header for this job
echo -------------------------------------------------------------------------------------->> %LOGPATH%\%LOGFILENAME%
echo  %CUR_DATE% %TIME%  TempFileCleanup v%VERSION%, executing as %USERDOMAIN%\%USERNAME% >> %LOGPATH%\%LOGFILENAME%
echo -------------------------------------------------------------------------------------->> %LOGPATH%\%LOGFILENAME%
 
title [CLEANING TEMP FILES v%VERSION%]
:: Status message to the user
echo.
echo  Starting temp file cleanup
echo  --------------------------
echo.
echo  Cleaning USER temp files...
:: This is ugly but it creates the log line.
echo. >> %LOGPATH%\%LOGFILENAME% && echo  ! Cleaning USER temp files... >> %LOGPATH%\%LOGFILENAME% && echo. >> %LOGPATH%\%LOGFILENAME%
 
:: User temp files, history, and random My Documents stuff
del /F /S /Q "%TEMP%" >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q "%SystemDrive%%HOMEPATH%\Local Settings\Temp\*.*" >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q "%SystemDrive%%HOMEPATH%\Recent\*.*" >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q "%SystemDrive%%HOMEPATH%\Local Settings\Temporary Internet Files\*.*" >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q "%SystemDrive%%HOMEPATH%\Local Settings\Application Data\ApplicationHistory\*.*">> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q "%SystemDrive%%HOMEPATH%\My Documents\*.tmp" >> %LOGPATH%\%LOGFILENAME% 2>NUL
 
echo.
echo  Done.
echo. >> %LOGPATH%\%LOGFILENAME% && echo  ! Done. >> %LOGPATH%\%LOGFILENAME% && echo. >> %LOGPATH%\%LOGFILENAME%
 
 
::::::::::::::::::::::::::::
:: SYSTEM CLEANUP SECTION :: -- Most stuff in here requires Admin rights
::::::::::::::::::::::::::::
echo.
echo  Cleaning SYSTEM temp files...
echo  ! Cleaning SYSTEM temp files... >> %LOGPATH%\%LOGFILENAME% && echo.>> %LOGPATH%\%LOGFILENAME%
 
:: System temp files
del /F /S /Q "%WINDIR%\TEMP\*" >> %LOGPATH%\%LOGFILENAME% 2>NUL
 
:: Root drive garbage (usually C drive)
del /F /Q "%SystemDrive%\*.bat"  >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q "%SystemDrive%\*.txt"  >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q "%SystemDrive%\*.log*" >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q "%SystemDrive%\*.jp*" >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q "%SystemDrive%\*.tmp" >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q "%SystemDrive%\*.bak" >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q "%SystemDrive%\*.backup" >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q "%SystemDrive%\*.exe" >> %LOGPATH%\%LOGFILENAME% 2>NUL
rmdir /S /Q %SystemDrive%\Temp >> %LOGPATH%\%LOGFILENAME% 2>NUL
 
:: This removes the Microsoft Office installation cache. Usually around ~1.5 GB
rmdir /S /Q %SystemDrive%\MSOCache >> %LOGPATH%\%LOGFILENAME% 2>NUL
 
:: This removes the Microsoft Windows installation cache. Can be up to 1.0 GB
rmdir /S /Q %SystemDrive%\i386 >> %LOGPATH%\%LOGFILENAME% 2>NUL
 
:: This removes files left over from installing NVIDIA drivers
rmdir /S /Q %SystemDrive%\NVIDIA >> %LOGPATH%\%LOGFILENAME% 2>NUL
 
:: This removes files left over from installing ATI drivers
rmdir /S /Q %SystemDrive%\ATI >> %LOGPATH%\%LOGFILENAME% 2>NUL
 
:: This removes files left over from installing AMD drivers
rmdir /S /Q %SystemDrive%\AMD >> %LOGPATH%\%LOGFILENAME% 2>NUL
 
:: This removes files left over from installing Dell drivers
rmdir /S /Q %SystemDrive%\Dell >> %LOGPATH%\%LOGFILENAME% 2>NUL
 
:: This removes files left over from installing Intel drivers
rmdir /S /Q %SystemDrive%\Intel >> %LOGPATH%\%LOGFILENAME% 2>NUL
 
:: This empties all recycle bins on Windows 7 and up
rmdir /s /q %SystemDrive%\$Recycle.Bin
 
:: This empties all recycle bins on Windows XP and Server 2003
rmdir /s /q %SystemDrive%\RECYCLER
 
:: Windows update logs & built-in backgrounds (space waste)
del /F /Q %WINDIR%\*.log >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q %WINDIR%\*.txt >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q %WINDIR%\*.bmp >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q %WINDIR%\*.tmp >> %LOGPATH%\%LOGFILENAME% 2>NUL
del /F /Q %WINDIR%\Web\Wallpaper\*.* >> %LOGPATH%\%LOGFILENAME% 2>NUL
rmdir /S /Q %WINDIR%\Web\Wallpaper\Dell >> %LOGPATH%\%LOGFILENAME% 2>NUL
 
:: Flash cookies
rmdir /S /Q "%appdata%\Macromedia\Flash Player\#SharedObjects\#SharedObjects" >> %LOGPATH%\%LOGFILENAME% 2>NUL
 
:: Windows "guided tour" annoyance
del %WINDIR%\system32\dllcache\tourstrt.exe >> %LOGPATH%\%LOGFILENAME% 2>NUL
del %WINDIR%\system32\dllcache\tourW.exe >> %LOGPATH%\%LOGFILENAME% 2>NUL
rmdir /S /Q %WINDIR%\Help\Tours >> %LOGPATH%\%LOGFILENAME% 2>NUL
 
echo.
echo  Done.
echo. >> %LOGPATH%\%LOGFILENAME%
echo  ! Done. >> %LOGPATH%\%LOGFILENAME%
echo. >> %LOGPATH%\%LOGFILENAME%
 
 
::::::::::::::::::::::::::::
:: Windows Server cleanup :: -- This section runs only if the OS is Windows Server 2000, 2003, 2008, or 2012
::::::::::::::::::::::::::::
:server_cleanup
 
:: 0. Check our operating system. If it's not a Server OS, skip this section.
IF '%IS_SERVER_OS%'=='no' goto :xp_2003
 
:: 1. If we made it here then we're on a Server OS, so go ahead and run server-specific tasks
echo.
echo  ! Windows Server operating system detected.
echo    Removing built-in media files (.wav, .midi, etc)...
echo.
echo. >> %LOGPATH%\%LOGFILENAME% && echo  ! Windows Server operating system detected. Removing built-in media files (.wave, .midi, etc)... >> %LOGPATH%\%LOGFILENAME% && echo. >> %LOGPATH%\%LOGFILENAME%
 
:: 2. Take ownership of the files so we can actually delete them. By default even Administrators have Read-only rights.
echo  ! Taking ownership of %WINDIR%\Media in order to delete files... && echo.
echo  ! Taking ownership of %WINDIR%\Media in order to delete files... >> %LOGPATH%\%LOGFILENAME% && echo. >> %LOGPATH%\%LOGFILENAME%
takeown /f %WINDIR%\Media /r /d y >> %LOGPATH%\%LOGFILENAME% 2>&1 && echo. >> %LOGPATH%\%LOGFILENAME%
icacls %WINDIR%\Media /grant administrators:F /t >> %LOGPATH%\%LOGFILENAME% && echo. >> %LOGPATH%\%LOGFILENAME%
 
:: 3. Do the cleanup
rmdir /S /Q %WINDIR%\Media>> %LOGPATH%\%LOGFILENAME% 2>&1
 
 
::::::::::::::::::::::::::::::::::::
:: Windows XP/2003 hotfix cleanup ::
::::::::::::::::::::::::::::::::::::
:xp_2003
:: This section tests for Windows XP/2003 hotfixes and deletes them if they exist.
:: These hotfixes use a lot of space so clearing them out is beneficial.
:: Really we should use a tool that deletes their corresponding registry entries, but oh well.
 
:: 0. Check Windows version. If it's not XP or 2003 then skip this whole section.
:: Test for XP. Yes, we do it twice. There's some insanity in Windows where sometimes it won't set the ERRORLEVEL correctly. Sigh.
wmic os get name | findstr "XP" >NUL
wmic os get name | findstr "XP" >NUL
        IF %ERRORLEVEL%==0 goto :hotfix_cleanup
        IF NOT %ERRORLEVEL%==0 goto :complete
:: Test for 2003. Yes, we do it twice. There's some insanity in Windows where sometimes it won't set the ERRORLEVEL correctly. Sigh.
wmic os get name | findstr "2003" >NUL
wmic os get name | findstr "2003" >NUL
        IF %ERRORLEVEL%==0 goto :hotfix_cleanup
        IF NOT %ERRORLEVEL%==0 goto :complete
 
:: 1. If we made it here then we're doing the cleanup. Go ahead and notify the user and log it.
:hotfix_cleanup
echo.
echo  ! Windows XP/2003 detected.
echo    Removing hotfix uninstallers...
echo.
echo. >> %LOGPATH%\%LOGFILENAME% && echo ! Windows XP/2003 detected. Removing hotfix uninstallers... >> %LOGPATH%\%LOGFILENAME%
 
:: 2. Build the list of hotfix folders. They always have "$" signs around their name, e.g. "$NtUninstall092330$" or "$hf_mg$"
pushd %WINDIR%
dir /A:D /B $*$ > %TEMP%\hotfix_nuke_list.txt 2>&1
 
:: 3. Do the hotfix clean up
for /f %%i in (%TEMP%\hotfix_nuke_list.txt) do (
        echo Deleting %%i...
        echo Deleted folder %%i >> %LOGPATH%\%LOGFILENAME%
        rmdir /S /Q %%i >> %LOGPATH%\%LOGFILENAME% 2>&1
        )
 
:: 4. Log that we are done with hotfix cleanup and leave the Windows directory
echo. >> %LOGPATH%\%LOGFILENAME% && echo ! Windows XP/2003 hotfix uninstaller cleanup complete. >> %LOGPATH%\%LOGFILENAME% && echo.>> %LOGPATH%\%LOGFILENAME%
del %TEMP%\hotfix_nuke_list.txt >> %LOGPATH%\%LOGFILENAME%
popd
 
 
::::::::::::::::::::::::::
:: Cleanup and complete ::
::::::::::::::::::::::::::
:complete
@echo off
echo -------------------------------------------------------------------------------------->> %LOGPATH%\%LOGFILENAME%
echo  %CUR_DATE% %TIME%  TempFileCleanup v%VERSION%, finished. Executed as %USERDOMAIN%\%USERNAME% >> %LOGPATH%\%LOGFILENAME%>> %LOGPATH%\%LOGFILENAME%
echo -------------------------------------------------------------------------------------->> %LOGPATH%\%LOGFILENAME%
echo.
echo  Cleanup complete.
echo.
echo  Log saved at: %LOGPATH%\%LOGFILENAME%
echo.
ENDLOCAL