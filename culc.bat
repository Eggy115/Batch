@echo off
@title:Calculator
setlocal EnableDelayedExpansion
color 0a
goto play

:play
cls
echo Can i have your name?
set /p name=
cls
echo Hello, !name! Do you want to use the
echo Calculator
echo 1.Yes
echo 2.No
set /p input=
if !input! equ 1 goto calc
if !input! equ 2 exit

:calc
cls
echo Add       = +
echo Subtract  = -
echo Divide    = /
echo Multiply  = *
echo Put your question here:
set /p equ=
set /a equ=!equ!
cls
echo Answer:!equ!
pause
goto calc