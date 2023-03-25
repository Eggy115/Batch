:: 
:: Program a Fairlight Audio Accelerator Card
:: Args (both optional):  [index] [filename]
::    index:    ordinal index of card to program 0-7, default=0
::    filename: name of .pof file in this folder, quoted if contains spaces
:: 
@ECHO off
SETLOCAL
SET FOPTION=
SET IOPTION=
SET INDEX=0
SET PROGFILE=

:: Change directory to the folder containing this file. 
pushd %~dp0

IF "%~1"=="/I" goto program
IF "%~2"=="/I" goto program

IF [%1]==[] goto program

SET PROGFILE="%~nx1"
IF %1 GEQ 0 (
    IF %1 LEQ 7 (
        SET INDEX=%1
        SET IOPTION=-i=%1
        SET PROGFILE="%~nx2"
    )
)
IF [%PROGFILE%] EQU [""] goto program

IF EXIST %PROGFILE% goto filespec
ECHO **** %PROGFILE% not found
pause
GOTO END

:: Get cmd line filename parameter
:filespec
SET FOPTION=-f=%PROGFILE%

:program
ECHO Programming Fairlight Audio Accelerator card %INDEX%.
ECHO Card type is selected in Fairlight Setup Utility
XFLASH -y -e -r -b=1 %IOPTION% %FOPTION%

:: Test return status
IF NOT ERRORLEVEL 10 GOTO teststatus2
SET TMPFILE=%TEMP%\junk.vbs
>  %TMPFILE% ECHO Set wshShell=CreateObject("WScript.Shell")
>> %TMPFILE% ECHO wshShell.Popup "The computer must be shutdown and restarted to complete the programming of your Fairlight Audio Accelerator card.  Please close any open files and Shutdown when the installation is done.", 0, "Program Fairlight Audio Accelerator", vbInformation+vbSystemModal
WSCRIPT.EXE %TMPFILE%
DEL %TMPFILE%
GOTO END

:teststatus2
IF ERRORLEVEL 2 GOTO END
if not errorlevel 1 goto okay

SET TMPFILE=%TEMP%\junk.vbs
>  %TMPFILE% ECHO Set wshShell=CreateObject("WScript.Shell")
>> %TMPFILE% ECHO wshShell.Popup "Fairlight Audio Accelerator card is currently in use, or not responding.", 0, "Program Fairlight Audio Accelerator", vbExclamation+vbSystemModal
WSCRIPT.EXE %TMPFILE%
DEL %TMPFILE%
popd
exit /B 1

:END
popd

