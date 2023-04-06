@echo off
ipconfig /all > tempIP.txt
for /F "tokens=2 delims=:" %%j in ('ipconfig /all ^| find "Host Name"') do set Host=%%j
set Host=%Host:~1%
ren tempIP.txt "%Host%.txt"