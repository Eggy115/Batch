@echo off
setlocal enabledelayedexpansion
goto :main

:main
	setlocal
		set a=1
		set b=2
		if %a% GEQ 0 (
			echo a is greater than zero
			set /a c=!a!+!b!
			if !c! LSS 5 (
				echo c is less than 5
			)else (
				echo c is greater than 5
			)
		)else (
			echo a is not greater than zero
		)
	endlocal
goto :eof