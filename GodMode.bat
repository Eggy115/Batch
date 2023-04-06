@echo off

rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem :: Cool little tool for making GodMode folders on Win7 x64 machines
rem :: to create this on your local machine, just run the file
rem :: to create it on another machine in the domain, add the machine name
rem :: (i.e.: GodMode tbhilb19956)
rem :: If there is no C:\Program Files (x86) it quits without writing the folder
rem :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


if not defined "%1" goto thispc

if not exist \\%1\C$\"Program Files (x86)" goto x32
md \\%1\c$\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}

echo.
echo GodMode Created.
echo.
goto end

:thispc
md c:\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}
echo.
echo GodMode Created.
echo.
goto end

:x32
echo. 
echo System is not Windows 7 64-bit. GodMode not created.
echo. 

:end