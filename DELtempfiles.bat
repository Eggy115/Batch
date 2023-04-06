@echo off
Title Clean up in progress
echo --------------------------------------
echo Closing Chrome
taskkill /F /IM "chrome.exe"
ipconfig /flushdns 
echo --------------------------------------
echo Beginning clean up
IF EXIST "C:\Users\" (
    for /D %%x in ("C:\Users\*") do (
		del /q /s /f "%%x\AppData\Local\Google\Chrome\User Data\Default\cache\*.*"
		del /q /s /f "\AppData\Local\Google\Chrome\User Data\Default\*Cookies*.*
        del /f /s /q "%%x\AppData\Local\Temp\*.*"
        del /f /s /q "%%x\AppData\Local\Microsoft\Windows\Temporary Internet Files\*.*"
        del /f /s /q "C:\Windows\Prefetch\*.*"
        del /f /s /q "C:\Windows\Temp\*.*"
		del /f /s /q "C:\WINDOWS\pchealth\ERRORREP\UserDumps\*.*"
    )
)
exit