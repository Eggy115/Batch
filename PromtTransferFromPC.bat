:: Windows user file transfer utility with exclusions.                         
:: Utility to transfer My Documents, My Pictures, Desktop and Favorites for the current user to the current     
:: user's H:\ drive, then to a new PC.  This script is designed to run from the H:\ drive itself, so no   
:: need to verify the destination exists.  This script must be placed in the user's H:\ drive 
:: with the file "exclude.txt" in order to run.  The exclude file skips folder under XP's \My Documents folder. 
:: (My Music, My Videos, My Google Gadgets, etc).
:: \My Pictures is excluded, then specifically copied later because it is not a child of \My Documents in Win 7 

:: This transfer utility (in 2 parts) can be used to transfer user files from XP or Win 7 to XP or Win 7 (universal) 

:: XCOPY switches I use here:
:: /E Copies directories and subdirectories, including empty ones.
:: /I If destination does not exist and copying more than one file, assumes that destination must be a directory.
:: /C Continues copying even if errors occur.
:: /Y Suppresses prompting to confirm you want to overwrite an existing destination file.
:: /Z Resumes the copy operation after a network error (if one occurs)

@echo off
echo input username
set /p input=""
cls
echo.
echo Moving files...
md %~dp0Transferred
md %~dp0Transferred\Favorites
md %~dp0Transferred\Desktop
md %~dp0Transferred\MyDocuments
md %~dp0Transferred\MyPictures
md %~dp0Transferred\Music
md %~dp0Transferred\Videos
md %~dp0Transferred\Chrome
md %~dp0Transferred\Outlook

:: I only transfer these folders presumably because they are the only "business relevant" files needed to keep 

:: Check version and jump to appropriate section (I only care about XP or Win7 )
rem VER | FINDSTR /IL "5.1." > NUL
rem IF %ERRORLEVEL% EQU 0 SET WinVersion=XP

rem VER | FINDSTR /IL "6.1." > NUL
rem IF %ERRORLEVEL% EQU 0 SET WinVersion=Win7

:: If the version is not Windows 7 or XP, let me know and then quit 
rem if not %ERRORLEVEL% EQU 0 goto Aborted
rem goto %winversion%

if exist C:\"Program Files (x86)" goto Win7

:XP
xcopy C:\"Documents and Settings"\%input%\Favorites\*.* %~dp0Transferred\Favorites /E /I /C /Y /Z
echo.
xcopy C:\"Documents and Settings"\%input%\Desktop\*.* %~dp0Transferred\Desktop /E /I /C /Y /Z
echo.
xcopy C:\"Documents and Settings"\%input%\"My Documents"\*.* %~dp0Transferred\MyDocuments  /E /I /C /Y /Z /EXCLUDE:exclude.txt
:: Note the exclusions - the other "My Pictures, My Videos" etc., folders are not children of \My Documents in Win 7  
echo.
xcopy C:\"Documents and Settings"\%input%\"My Documents"\"My Pictures"\*.* %~dp0Transferred\MyPictures  /E /I /C /Y /Z
echo.
xcopy C:\"Documents and Settings"\%input%\"My Documents"\"My Music"\*.* %~dp0Transferred\Music  /E /I /C /Y /Z
echo.
xcopy C:\"Documents and Settings"\%input%\"My Videos"\"My Pictures"\*.* %~dp0Transferred\Videos  /E /I /C /Y /Z
echo.
xcopy "C:\Documents and Settings\%input%\Application Data\Local\Chrome\User Data"*.* %~dp0Transferred\Chrome  /E /I /C /Y /Z
echo.
xcopy "C:\Documents and Settings\%input%\Application Data\Local\Microsoft\Outlook\"*.pst %~dp0Transferred\Outlook\  /E /I /C /Y /Z
echo.
goto end

:Win7
xcopy C:\Users\%input%\Favorites\*.* %~dp0Transferred\Favorites /E /I /C /Y /Z
echo.
xcopy C:\Users\%input%\Desktop\*.* %~dp0Transferred\Desktop /E /I /C /Y /Z
echo.
xcopy C:\Users\%input%\Documents\*.* %~dp0Transferred\MyDocuments  /E /I /C /Y /Z
:: No exclusions are required in Win 7 because they are separate at the parent level 
echo.
xcopy C:\Users\%input%\Pictures\*.* %~dp0Transferred\MyPictures  /E /I /C /Y /Z
echo.
xcopy C:\Users\%input%\Music\*.* %~dp0Transferred\Music  /E /I /C /Y /Z
echo.
xcopy C:\Users\%input%\Videos\*.* %~dp0Transferred\Videos  /E /I /C /Y /Z
echo.
if exist C:\Users\%input%\AppData\Local\Google\Chrome xcopy "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\"*.* %~dp0Transferred\Chrome  /E /I /C /Y /Z
echo. 
if exist C:\Users\%input%\AppData\Local\Microsoft\Outlook\*.pst xcopy %USERPROFILE%\AppData\Local\Microsoft\Outlook\*.pst %~dp0Transferred\Outlook\  /E /I /C /Y /Z
goto end


:Aborted
echo.
echo This version of Windows is not recognized, or the query failed.
echo Move the files manually
echo.
echo Press any key to exit...
pause>nul


:end
exit
