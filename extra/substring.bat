@echo off
setlocal enabledelayedexpansion

set string=This is a string
echo %string%

::Substring starting from 0 and taking the next 4 characters from there
set substring=!string:~0,4!
echo %substring%

::Substring starting from 4 and taking the next 4 characters
set substring=!string:~4,4!
echo %substring%

::Substring starting from 0 until the end of the string - 4
set substring=!string:~0,-4!
echo %substring%