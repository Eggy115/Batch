@echo off
rem check user status.
echo Check user's AD account to see if it is locked.
set /p loginid="Please enter the AD username:"
net user /domain %loginid% | find "Account active"
set /p continue="Is the account locked? Y/N"
if (%continue%)==(y) goto reset
if (%continue%)==(n) goto end_nolocked
:reset
echo Unlocking AD Account.
rem set /p loginid="Please enter the username:"
rem here is where we unlock and change the password if needed.
set /p reset="Do you also want to reset the AD password? Y/N"
if (%reset%)==(n) goto noreset
set /p newpassword="Enter password:"
NET USER %loginid% %newpassword% /DOMAIN /ACTIVE:YES
echo User ID %loginid% has been unlocked and the password set to %newpassword%.
goto end
:noreset
rem tell the user what the status is
NET USER %loginid% /DOMAIN /ACTIVE:YES
echo User ID %loginid% has been unlocked.
:end
pause
exit
:end_nolocked
echo User ID %loginid% is not locked out of AD.
pause
exit