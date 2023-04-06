wmic product where "name like 'Java%%'" call uninstall /nointeractive
wmic product where "name like 'Java(TM)%%'" call uninstall /nointeractive
wmic product where "name like 'Java 7%%'" call uninstall /nointeractive
wmic product where "name like 'Java 8%%'" call uninstall /nointeractive

reg query hklm\software\classes\installer\products /f "java(tm) 6" /s | find "HKEY_LOCAL_MACHINE" > deljava.txt
for /f "tokens=* delims= " %%a in (deljava.txt) do reg delete %%a /f
del deljava.txt
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\JreMetrics" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\wow6432node\JavaSoft" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\wow6432node\JreMetrics" /f