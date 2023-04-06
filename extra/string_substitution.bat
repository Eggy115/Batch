@echo off
goto :main

:main
	set string=hello hello world
	::substitute hello with goodbye
	set string=%string:hello=goodbye%
	echo %string%
exit /b
