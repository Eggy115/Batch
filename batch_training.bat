::MS-Batch is an interpreted language.
::It is case-insensitive.
::In Windows, folders are delimited by forward or backward slashes.

::to avoid any harm from accidentally running this file, exit immediately
exit /b 0

::@ prefix disables command-line output for one line
@dir

::disable command-line outputting every line that was run in plain-text
@echo off

::list files in the current directory
dir

::list files in a specific directory
dir Desktop

::output whatever comes after (can be used with variables)
echo Hello

::output a blank line
echo.

::Wait for any key to be pressed to resume operation
pause

::clear screen
cls

::set a variable and print it to the console
set myvariable=Hello
echo %myvariable%

::print current directory
echo %cd%

::typing set by itself returns all variable names and their values (including system variables)
set

::print out all variables starting with the letter h
set h

::mathematical expression
set /a number=1+1
echo %number%

::get user input
set /p name=Please enter your name
echo %name%

::Check if a variable is defined for conditional handling
::Parentheses are mandatory in the if else statement
set a=1
if defined a (echo yes) else (echo no)

::list all programs on path
::Note that the parentheses are mandatory.
for %program in (%path%) do (echo %program)

::make directory (md or mkdir)
md new_dir
::make two folders, one called hello, one called world
md hello world
::make one folder called hello world
md "hello world"

::remove directory (rd or rmdir)
::only deletes empty directories, unless you specify /s, then it deletes the entire directory tree
rd new_dir

::delete all contents of directory
del new_dir

::change directory (cd or chdir)
cd new_dir

::change to parent
cd ..

::move a file to a new location
move test.txt new_dir/test.txt

::copy a file to a new location
copy test.txt new_dir/test.txt

::copies file and directory trees
xcopy folder1 folder2 /E

::escape character for % is %
::escape character for anything else is ^ (caret)
::NOTE: dont end a file with a caret, the script will keep running forever. Always end script with a blank line

::The colon operator (:) as a prefix marks a label, which can be skipped to using goto
goto :label
:label

::Every batch file has an implicit :eof label at the end of the file
::The line below ends the execution of the program
goto :eof

rem This is a comment // typically not used, as rem actually takes up some processing time

:: & symbol chains statements together on a single line

::display file contents
type %file%

::change colour of the command line window
color 0a