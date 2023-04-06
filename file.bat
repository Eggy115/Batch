@echo off

TITLE Downloads File Finder

:Menu

set dct="C:\Users\Pepsi\Downloads"

cd %dct%

cls

ECHO.

ECHO =========================================================

ECHO Downloads Folder Menu by David Burris

ECHO =========================================================

ECHO.

ECHO 1. Open a file

ECHO 2. Open a folder

ECHO 3. Exit

ECHO.

ECHO ---------------------------------------------------------

ECHO Please enter your selection:

set/p op=

if %op%==1 goto 1

if %op%==2 goto 2

if %op%==3 goto 3

goto Error1

:1

cls

dir /O

ECHO.

ECHO =========================================================

ECHO Please copy and paste your file name

ECHO =========================================================

set/p file=

"%file%"

goto Menu

:2

cls

dir /O

ECHO.

ECHO =========================================================

ECHO Please copy and paste your folder

ECHO =========================================================

set/p dct=

cd %dct%

goto Submenu

:3

Exit

:Error1

cls

ECHO.

ECHO You have entered an invalid selection. Press any key to return to the Main Menu.

PAUSE >null

goto Menu

:Error2

cls

ECHO.

ECHO You have entered an invalid selection. Press any key to return to the Submenu.

PAUSE >null

goto Submenu

:Submenu

cls

dir /O

ECHO.

ECHO 1. Open a file

ECHO 2. Open a folder

ECHO 3. Main Menu

ECHO.

ECHO ---------------------------------------------------------

ECHO Please enter your selection:

set/p opp=

if %opp%==1 goto 11

if %opp%==2 goto 2

if %opp%==3 goto Menu

goto Error2

:11

cls

dir /O

ECHO.

ECHO =========================================================

ECHO Please copy and paste your file name

ECHO =========================================================

set/p file=

"%file%"

goto Submenu