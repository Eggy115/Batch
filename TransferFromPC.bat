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
echo.
echo Moving files...
md %~dp0%username%
md %~dp0%username%\Favorites
md %~dp0%username%\Desktop
md %~dp0%username%\MyDocuments
md %~dp0%username%\MyPictures
md %~dp0%username%\Music
md %~dp0%username%\Videos
md %~dp0%username%\Chrome
md %~dp0%username%\Outlook
md %~dp0%username%\xcor
md %~dp0%username%\maps
md %~dp0BHN_TPA_Fiber_Map_System_PROVIEWER


:Win7
xcopy %USERPROFILE%\Favorites\*.* %~dp0%username%\Favorites /E /I /C /Y /Z
echo.
xcopy %USERPROFILE%\Desktop\*.* %~dp0%username%\Desktop /E /I /C /Y /Z
echo.
xcopy %USERPROFILE%\Documents\*.* %~dp0%username%\MyDocuments  /E /I /C /Y /Z
:: No exclusions are required in Win 7 because they are separate at the parent level 
echo.
xcopy %USERPROFILE%\Pictures\*.* %~dp0%username%\MyPictures  /E /I /C /Y /Z
echo.
xcopy %USERPROFILE%\Music\*.* %~dp0%username%\Music  /E /I /C /Y /Z
echo.
xcopy %USERPROFILE%\Videos\*.* %~dp0%username%\Videos  /E /I /C /Y /Z
echo.
xcopy C:\ProgramData\Xcor\*.* %~dp0%username%\xcor  /E /I /C /Y /Z
echo.
xcopy C:\maps\*.* %~dp0%username%\maps  /E /I /C /Y /Z
echo.
xcopy C:\BHN_TPA_Fiber_Map_System_PROVIEWER\*.* %~dp0%BHN_TPA_Fiber_Map_System_PROVIEWER  /E /I /C /Y /Z
echo.
if exist %USERPROFILE%\AppData\Local\Google\Chrome xcopy "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\"*.* %~dp0%username%\Chrome  /E /I /C /Y /Z
echo. 
if exist %USERPROFILE%\AppData\Local\Microsoft\Outlook\*.pst xcopy %USERPROFILE%\AppData\Local\Microsoft\Outlook\*.pst %~dp0%username%\Outlook\  /E /I /C /Y /Z
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
