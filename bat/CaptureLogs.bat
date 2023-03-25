@ECHO OFF

REM #########################################
REM FILES to be archived
SET DAVINCI_LOG=Support\logs
SET DAVINCI_CRASHTXT=Support\crash_archive.txt
SET DAVINCI_PREFERENCES=Preferences
SET FUSION_PROFILES=Support\Fusion\Profiles
REM Exclude folders
SET EXCLUDE_CREDENTIALS_FOLDER=Preferences\.credentials*
SET EXCLUDE_FL_PRESETS_FOLDER=Preferences\Fairlight\Presets*
SET EXCLUDE_PREFERENCES_CONF=Preferences\*.conf
REM #########################################

REM #########################################
REM Get DateTime string to ensure log files are uniq
for /f "tokens=1,2,3,4 delims=/ " %%a in ("%date%") do set wday=%%a&set month=%%b&set day=%%c&set year=%%d
for /f "tokens=1,2,3,4 delims=:." %%a in ("%time%") do set hh=%%a&set mm=%%b&set ss=%%c&set mil=%%d
SET LOGZIP_FILE=DaVinci-Resolve-logs-%year%%month%%day%_%hh%%mm%%ss%.zip
SET LOGZIP_FULLPATH=%userprofile%\Desktop\%LOGZIP_FILE%
REM zip.exe must be in the same level as this script
SET ZIPEXEPATH=%~dp0
REM #########################################

pushd "%APPDATA%\Blackmagic Design\DaVinci Resolve"
"%ZIPEXEPATH%\zip.exe" "%LOGZIP_FULLPATH%" -S -r "%DAVINCI_LOG%" -r "%DAVINCI_PREFERENCES%" "%DAVINCI_CRASHTXT%" "%FUSION_PROFILES%" -x "%EXCLUDE_CREDENTIALS_FOLDER%" -x "%EXCLUDE_FL_PRESETS_FOLDER%" -x "%EXCLUDE_PREFERENCES_CONF%"
popd

REM #########################################
REM popup message
SET POPUPMSG="%LOGZIP_FILE% has been saved to the Desktop."
> "%TEMP%\usermessage.vbs" ECHO Set wshShell = CreateObject( "WScript.Shell" )
>> "%TEMP%\usermessage.vbs" ECHO dim wshMessage: wshMessage =  WScript.Arguments.UnNamed(0)
>> "%TEMP%\usermessage.vbs" ECHO wshShell.Popup  wshMessage, 10, "DaVinci Resolve", 64
WSCRIPT.EXE "%TEMP%\usermessage.vbs" %POPUPMSG%
DEL "%TEMP%\usermessage.vbs"
REM #########################################
