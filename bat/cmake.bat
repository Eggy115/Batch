
if "%VSCMD_TEST%" NEQ "" goto :test
if "%VSCMD_ARG_CLEAN_ENV%" NEQ "" goto :clean_env

:export_path

if not exist "%VSINSTALLDIR%Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin" goto :error_setting_path
if not exist "%VSINSTALLDIR%Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja" goto :error_setting_path
set "PATH=%PATH%;%VSINSTALLDIR%Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;%VSINSTALLDIR%Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja"
goto :end

:error_setting_path
exit /B 1

goto :end


@REM -----------------------------------------------------------------------------------------------------------------
:test

set __VSCMD_TEST_FailCount=0

setlocal

@REM -- Check for CMake.exe, which is installed to the installation specific path --
@echo [TEST:%~nx0] Checking for cmake.exe...
where cmake.exe > NUL 2>&1
if "%ERRORLEVEL%" NEQ "0" (
    set /A __VSCMD_TEST_FailCount=__VSCMD_TEST_FailCount+1
    echo [ERROR:%~nx0] cmake.exe was not found
)

@REM -- Check for Ninja.exe, which is installed to the installation specific path --
@echo [TEST:%~nx0] Checking for ninja.exe...
where ninja.exe > NUL 2>&1
if "%ERRORLEVEL%" NEQ "0" (
    set /A __VSCMD_TEST_FailCount=__VSCMD_TEST_FailCount+1
    echo [ERROR:%~nx0] ninja.exe was not found
)
endlocal & set __VSCMD_TEST_FailCount=%__VSCMD_TEST_FailCount%

@REM return value other than 0 if tests failed.
if "%__VSCMD_TEST_FailCount%" NEQ "0" (
   set __VSCMD_Test_FailCount=
   exit /B 1
)

set __VSCMD_Test_FailCount=
exit /B 0

@REM -----------------------------------------------------------------------------------------------------------------
:clean_env

@REM this script only modifies PATH, so additional clean-up is not required.

goto :end

@REM -----------------------------------------------------------------------------------------------------------------
:end
exit /B 0