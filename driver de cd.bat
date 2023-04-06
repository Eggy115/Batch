@echo off
for /f %%a in ('"wmic cdrom get drive | find ":""') do set Driver=%%a
echo Driver de cd aberto.
nircmd cdrom open %Driver%
pause
cls
echo Driver de cd fechado
nircmd cdrom close %Driver%
pause