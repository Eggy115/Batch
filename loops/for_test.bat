@echo off
setlocal enabledelayedexpansion
goto :main

:main
	setlocal
		::iterate through a set (can be words or strings)
		for %%i in ( 1 2 3 ) do (
			echo %%i
		)
		
		echo.
		
		::iterate through a set of numbers given a start, step and end
		set start=1
		set step=1
		set end=5
		for /l %%i in (%start% %step% %end%) do (
			echo %%i
		)
		
		echo.
		
		::iterate through directories matched by search argument (* is wildcard)
		for /d %%d in ( * ) do (
			echo %%d
		)
		
		echo.
		
		::iterate through file contents (recursively) by search argument
		for /r %%f in ( *.bat) do (
			echo %%f
		)
		
		echo.
		
		::iterate through file contents
		set filename=while.bat
		::"delims= sets whitespace as a delimiter
		::skip=3 skips the first three lines of the file
		::tokens=2,3,4 only extracts the second, third and fourth fields on that line of file contents
		::eol defines which symbols are interpreted as end of line symbols (anything after them will be skipped)
		for /f "tokens=1,2,3 skip=3 eol=@ delims= " %%f in (%filename%) do (
			rem note here that %%g was never defined, but this is representing the second token, generated automatically by the for loop (same for %%h)
			echo %%f ......... %%g ............ %%h
		)
		
		echo.
		
		::get drive letter from cd
		for /f "delims=\" %%f in ('cd') do echo %%f
		
		echo.
		
		::loop through first 3 words of a strings
		set string=This is a string
		for /f "tokens=1,2,3" %%a in ("!string!") do (
			echo %%a %%b %%c
		)
	endlocal
goto :eof
