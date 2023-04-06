@echo off
setlocal enabledelayedexpansion
goto :main

:main
	setlocal
		::if instead we typed echo j|choice, the output of echo would be the input to choice, i.e. it would choose yes
		choice
		
		::CHOICE returns ERRORLEVEL and sets it to 2 if no has been chosen
		if errorlevel 2 (echo You have chosen no) else (echo You have chosen yes)
	endlocal
goto :eof
