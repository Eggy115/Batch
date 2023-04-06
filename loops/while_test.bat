@echo off
setlocal enabledelayedexpansion
goto :main

:main
	setlocal
		set /a counter=0
		set /a limit=10
		
		:while
		echo counter is !counter!
		set /a counter=!counter! + 1
		if !counter! LEQ !limit! (
			goto :while
		)
		
		echo.
		echo Finished while loop
	endlocal
goto :eof