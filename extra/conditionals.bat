@echo off
goto :main

::conditionals

:is_file
	setlocal
	set filename=%~1
	if exist filename (
		echo %filename% is not a file
		exit /b %ERRORLEVEL%
	)
	endlocal
goto :eof

:are_equal
	::EQU equal
	::NEQ not equal
	::LSS less than
	::GTR greater than
	::LEQ less than or equal
	::GEQ greater than or equal
	::other keywords: NOT and EXIST
	if %~1 EQU %~2 (set %~3=1)
	if %~1 NEQ %~2 (set %~3=0)
goto :eof

:main
	setlocal
	
	::check if hello.txt is a file
	call :is_file hello.txt
	
	call :are_equal 1 2 rv
	
	::spacing needs to be exactly like this or if else doesnt work!
	if %rv% EQU 1 (
		echo 1 and 2 are equal
	)else (
		echo 1 and 2 are not equal
	)
	
	::one-liner
	if %rv% EQU 1 (echo 1 and 2 are equal) else (echo 1 and 2 are not equal)

	endlocal
	exit /b %ERRORLEVEL%
goto :eof