@echo off
Rem Cleanse Computer
wmic product where "name like 'Safe %%'" call uninstall /nointeractive
wmic product where "name like 'Hive %%'" call uninstall /nointeractive
exit