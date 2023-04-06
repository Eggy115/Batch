@echo off
title MY PROGRAM
color a
echo WELCOME
echo.
echo 1.)START
echo 2.)EXIT
echo.
set /p var=YOUR CHOICE:
if %var%==1 goto HELLO
if %var%==2 exit
:HELLO
cls
echo PLEASE CHOOSE AN OPTION
echo.
echo 1.)OPEN GOOGLE
echo 2.)OPEN EMAIL
echo 3.)SHUTDOWN COMPUTER
echo 4.)EXIT
echo.
set /p var=YOUR CHOICE:
if %var%==1 start www.google.com
if %var%==2 start www.gmail.com
if %var%==3 shutdown -s
if %var%==4 exit
pause
exit