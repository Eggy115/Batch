for /F "tokens=*" %%A in ("C:\Users\JLPrice_pci.CORP\Desktop\working\pclist.txt") do (
    echo.   
    echo %%A >> "C:\Users\JLPrice_pci.CORP\Desktop\working\RAM_LOG.txt"
    systeminfo /s:%%A | findstr /C:"Total Physical Memory" >> "C:\Users\JLPrice_pci.CORP\Desktop\working\RAM_LOG.txt"
)
pause

wmic /NODE:@"C:\scripts\pclist.txt" /APPEND:"C:\scripts\RAM_LOG.txt" computersystem get name, TotalPhysicalMemory

systeminfo | findstr /c:"Host Name"
systeminfo | findstr /c:"Domain"
systeminfo | findstr /c:"OS Name"
systeminfo | findstr /c:"OS Version"
systeminfo | findstr /c:"System Manufacturer"
systeminfo | findstr /c:"System Model"
systeminfo | findstr /c:"System type"
systeminfo | findstr /c:"Total Physical Memory"
ipconfig | find /i "IPv4"