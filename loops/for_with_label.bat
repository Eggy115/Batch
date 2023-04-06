@echo off
setlocal enabledelayedexpansion
goto :main

:myfunction
	setlocal
		echo I am being called
	endlocal
goto :eof

:for
	setlocal
		set counter=0
		set limit=%~1
		set function=%~2

		:loop
		if !counter! LSS !limit! (
			call :!function!
			set /a counter=!counter! + 1
			goto :loop
		)
	endlocal
goto :eof

:main
	setlocal
		call :for 10 myfunction
	endlocal
goto :eof