@echo off
setlocal enabledelayedexpansion
goto :main

:main
	setlocal
		::stdout 1
		::stderr 2
		
		::sends stdout to new_file.txt
		dir /b > test_dir/new_file.txt
		
		::sends stdout to new_file.txt
		dir /b 1> test_dir/new_file.txt
		
		::sends stderr to new_file.txt
		dir /b 2>test_dir/new_file.txt
		
		::sends stdout and stderr to new_file.txt
		dir /b > test_dir/new_file.txt 2>&1
		
		::Note that > overwrites anything previously written to the file
		:: >> appends to the file instead
		echo. >> test_dir/new_file.txt
		echo Hello >> test_dir/new_file.txt
		
		echo.
		
		echo < test_dir/new_file.txt
	endlocal
goto :eof