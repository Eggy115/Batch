@echo off
goto :main

echo Starting...

:function1
	echo Function 1
goto :eof

:function_with_argument
	::print the first argument passed to the function
	set input_variable=%~1
	echo %input_variable%
goto :eof

:function_with_return
	set %~1=2
	set %~2=3
goto :eof

:function_with_local_scope
	setlocal
	set x=1
	echo Function says x is %x%
	endlocal
goto :eof

:main
	setlocal
	echo Start of main function
	call :function1
	set variable="This is some text that is being passed in"
	::When passing in delimited string arguments (surrounded with quotation marks, we need to pass argument with %var%
	call :function_with_argument %variable%
	
	set number1=1
	::When passing in non-quotation mark delimited arguments, dont use percentage signs to pass arguments
	::Note: number2 is not defined, but it is returned by :function_with_return
	call :function_with_return number1 number2
	echo %number1%
	echo %number2%
	
	set x=2
	goto :function_with_local_scope
	echo Main says x is

	echo End of main function
	endlocal
goto :eof