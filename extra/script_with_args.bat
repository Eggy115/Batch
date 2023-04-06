@echo off

echo List of arguments:
echo.
for %%a in (%*) do (
	echo     %%a
)

echo.

set sum=0
for %%a in (%*) do (set /a sum=sum+%%a)
echo sum of arguments is %sum%