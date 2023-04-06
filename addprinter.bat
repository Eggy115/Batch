@Echo off
REM  	key this command in a Command Prompt window:
REM 	You do not need the leading \\ for the computer name or server name
REM     addprinter computer printserver\theprinter

@Echo On
rundll32 printui.dll,PrintUIEntry /ga /c\\%1 /n\\%2
@Echo off

REM Going to restart the spooler so the computer will display that it is installed.
@Echo On
start /wait sc \\%1 stop spooler
@Echo off

@Echo On
start /wait sc \\%1 start spooler