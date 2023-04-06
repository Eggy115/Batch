@echo off
for /f "tokens=*" %%i in (c:\scripts\list.txt) do regedit.exe /S c:\scripts\trusted.reg
IF "%errorlevel%" EQU "1" (
echo %i >> c:\scripts\recheck.txt
)
pause