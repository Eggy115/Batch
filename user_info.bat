@echo off
echo input username
set /p input=""
cls
echo 
net user %input% /domain
pause 