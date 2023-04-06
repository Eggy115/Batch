Title Back up started!
@echo on
echo.
robocopy c:\scripts\ x:\scripts\ /MIR /FFT /R:3 /W:2 /Z /MT:4
echo.
robocopy %USERPROFILE%\Favorites\ x:\backup\Favorites\ /MIR /FFT /R:3 /W:2 /Z /MT:4
echo.
robocopy %USERPROFILE%\Documents\ x:\backup\MyDocuments\ /MIR /FFT /R:3 /W:2 /Z /MT:4
echo.
robocopy %USERPROFILE%\Pictures\ x:\backup\MyPictures\ /MIR /FFT /R:3 /W:2 /Z /MT:4
:end
exit

