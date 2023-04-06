@echo off
goto :main

:increment
	setlocal
	endlocal & set /a %~1=%~2+1
goto :eof

:main
	setlocal
	set x=1
	
	::need to pass in name and value of variable separately to properly set it
	call :increment x %x%
	
	echo x is now %x%
	endlocal
goto :eof