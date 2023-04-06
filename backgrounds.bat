rem wallpaper
md c:\bgs
xcopy *.jpg c:\bgs\ /E /I /C /Y /Z
reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "c:\bgs\wallpaper.jpg" /f

rem start screen
xcopy *.jpg %windir%\system32\oobe\info\backgrounds /E /I /C /Y /Z
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background" /f /v OEMBackground /t REG_DWORD /d 00000001
xcopy GroupPolicy c:\windows\system32\GroupPolicy /E /I /C /Y /Z
pause