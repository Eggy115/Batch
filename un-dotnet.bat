@ECHO OFF
cls
TITLE Uninstalling Java . . .

wmic product where "name like 'Microsoft .NET Framework %%'" call uninstall /nointeractive
goto END

:END
pause
@echo Java has been uninstalled. . . 