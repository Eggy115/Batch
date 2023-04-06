@echo off

goto :main

:increment_two_numbers
	setlocal
	endlocal
	
	::return values cannot be placed in local scope

	::rv1
	set /a %~3=%~1+1
	
	::rv2
	set /a %~4=%~2+1
goto :eof

:main
	setlocal
	set a=1
	set b=2
	echo a and b are %a% and %b%
	call :increment_two_numbers a b rv1 rv2
	echo a and b are now %rv1% and %rv2%
	endlocal
goto :eof