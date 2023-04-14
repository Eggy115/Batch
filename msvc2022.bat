@echo off
rem To be used on MS-Windows for Visual C++ 2022.
rem See INSTALLpc.txt for information.
rem
rem Usage:
rem   For x86 builds run this with "x86" option:
rem     msvc2022 x86
rem   For x64 builds run this with "x64" option:
rem     msvc2022 x64

set "VSVEROPT=-version [17.0^,18.0^)"
call "%~dp0msvc-latest.bat" %*
set VSVEROPT=
