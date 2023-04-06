FORFILES /P %WINDIR%\servicing\Packages /M Microsoft-Windows-InternetExplorer-*11.*.mum /c "cmd /c echo Uninstalling package @fname && start /w pkgmgr /up:@fname /quiet /norestart"
FORFILES /P %WINDIR%\servicing\Packages /M Microsoft-Windows-InternetExplorer-*10.*.mum /c "cmd /c echo Uninstalling package @fname && start /w pkgmgr /up:@fname /quiet /norestart"
FORFILES /P %WINDIR%\servicing\Packages /M Microsoft-Windows-InternetExplorer-*9.*.mum /c "cmd /c echo Uninstalling package @fname && start /w pkgmgr /up:@fname /quiet /norestart"

wmic product where name="Dell Digital Delivery" call uninstall /nointeractive
wmic product where name="Microsoft Office" call uninstall /nointeractive
wmic product where name="Dell Client System Update" call uninstall /nointeractive
wmic product where name="Dell Protected Workspace" call uninstall /nointeractive

"C:\Program Files (x86)\InstallShield Installation Information\{0ED7EE95-6A97-47AA-AD73-152C08A15B04}\setup.exe" -runfromtemp -l0x0409 -removeonly

TIMEOUT /T 60

cd C:\Windows\System32\
gpupdate.exe /force /boot

shutdown -f -t 00 -r