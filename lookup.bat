::Works when searching for a machine on the same network.
::ARP requests for addresses outside the subnet won't be sent at all.
 
@echo off
set /p pc="Computer Name: "
 
::Query's the PC name with it's mac address, then uses that mac address to find the IP associated with it
for /f "tokens=2 delims==" %%i in ('nbtstat -a "%pc%" ^| find "MAC A"') do (for /f %%G in ('arp -a ^| find /i "%%i"') do echo %%G)
 
pause>null