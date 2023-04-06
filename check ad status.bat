@echo off
rem check user status.
:start
cls
title AD account unlock tool.
echo.
echo.
echo *************************************************************
echo Enter the username to check account status.
echo.
echo With this tool you can verify that an account is unlocked,
echo unlock and account and reset an account password.
echo.
echo Account Active YES means the account is not locked.
echo Account Active NO means the account is locked.
echo *************************************************************
echo.
set /p loginid="Please enter the AD username:"
net user /domain %loginid% | find "Account active"
echo.
set /p continue="Is the account locked? Y/N"
if (%continue%)==(y) goto reset
if (%continue%)==(n) goto end_nolocked
:reset
echo.
echo.
echo Unlocking AD Account.
echo.
echo.
rem set /p loginid="Please enter the username:"
rem here is where we unlock and change the password if needed.
set /p reset="Do you also want to reset the AD password? Y/N"
if (%reset%)==(n) goto noreset
echo.
set /p newpassword="Enter password:"
echo.
NET USER %loginid% %newpassword% /DOMAIN /ACTIVE:YES
echo.
echo User ID %loginid% has been unlocked and the password set to %newpassword%.
echo.
goto end
:noreset
rem tell the user what the status is
NET USER %loginid% /DOMAIN /ACTIVE:YES
echo.
echo User ID %loginid% has been unlocked.
:end
pause
goto start
:end_nolocked
echo User ID %loginid% is not locked out of AD.
pause
goto start