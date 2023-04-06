@ECHO OFF
cls
TITLE Uninstalling Java . . .
wmic product where "name like 'Java %%'" call uninstall /nointeractive
exit