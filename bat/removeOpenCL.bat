@echo off

REM Check if OpenCL.dll exists in the system location. If yes, remove the OpenCL.dll installed by Resolve
SET SYSTEM32=%WINDIR%\System32

if NOT EXIST "%SYSTEM32%\OpenCL.dll" (
	exit 0
)

pushd "%PROGRAMFILES%\Blackmagic Design\DaVinci Resolve"
if EXIST "OpenCL.dll" (
    del /Q "OpenCL.dll"
)
popd

exit 0
