
if "%VSCMD_TEST%" NEQ "" goto :test
if "%VSCMD_ARG_CLEAN_ENV%" NEQ "" goto :clean_env

if "%VSCMD_DEBUG%" GEQ "3" (
    @REM In order to avoid noise, we usually redirect stdout/stderr output from calling 'reg.exe' to nul.
    @REM However, to get a full trace (@echo off is NOT called), we have a separate set of calls that 
    @REM do not redirect stdout/stderr output when VSCMD_DEBUG >= 3.
    call :perf_tools_query_verbose
    goto :export_path
)

call :perf_tools_query
goto :export_path

:export_path

if not exist "%__collection_tools%" goto :after_processing_collection_tools
set "PATH=%__collection_tools%;%PATH%"
@REM check to see if we are targetting amd64, if so place the 64bit collection tools path before the 32bit one
if "%VSCMD_ARG_TGT_ARCH%" == "x64" set "PATH=%__collection_tools%\x64;%PATH%"

:after_processing_collection_tools
set __collection_tools=

if not exist "%VSINSTALLDIR%Team Tools\Performance Tools" goto :after_performance_tools_path
set "PATH=%VSINSTALLDIR%Team Tools\Performance Tools;%PATH%"
@REM check to see if we are targetting amd64, if so update to use 64bit vsinstr
if "%VSCMD_ARG_TGT_ARCH%" == "x64" set "PATH=%VSINSTALLDIR%Team Tools\Performance Tools\x64;%PATH%"

:after_performance_tools_path

goto :end

@REM -----------------------------------------------------------------------------------------------------------------
@REM Get the performance tools shared component path from the registry.
:perf_tools_query
call :perf_tools_query_helper HKLM\SOFTWARE > nul 2>&1
call :perf_tools_query_helper HKLM\SOFTWARE\Wow6432Node > nul 2>&1
exit /B 0

:perf_tools_query_verbose
@REM We define a separate "verbose" version for trace-level debugging which should be exactly the same
@REM except that stdout/stderr are not redirected to nul.
call :perf_tools_query_helper HKLM\SOFTWARE 
call :perf_tools_query_helper HKLM\SOFTWARE\Wow6432Node 
exit /B 0

:perf_tools_query_helper
@REM Query registry path for the perf tools singleton installation component
for /F "tokens=1,2*" %%i in ('reg query "%1\Microsoft\VisualStudio\VSPerf" /v "CollectionToolsDir2019"') DO (
    if "%%i"=="CollectionToolsDir2019" (
        SET "__collection_tools=%%k"
    )
)

if "%VSCMD_DEBUG%" GEQ "2" echo [DEBUG:~nx0] after reg query '%1', __collection_tools='%__collection_tools%'

exit /B 0

@REM -----------------------------------------------------------------------------------------------------------------
:test

set __VSCMD_TEST_FailCount=0

setlocal

@REM -- Check for VSPerfReport.exe, which is installed to the installation specific path --
@echo [TEST:%~nx0] Checking for vsperfreport.exe...
where vsperfreport.exe > NUL 2>&1
if "%ERRORLEVEL%" NEQ "0" (
    set /A __VSCMD_TEST_FailCount=__VSCMD_TEST_FailCount+1
    echo [ERROR:%~nx0] vsperfreport.exe was not found
)

@REM -- Check for VSPerfMon.exe, which is installed to the shared component path --
@echo [TEST:%~nx0] Checking for vsperfmon.exe...
where vsperfmon.exe > NUL 2>&1
if "%ERRORLEVEL%" NEQ "0" (
    set /A __VSCMD_TEST_FailCount=__VSCMD_TEST_FailCount+1
    echo [ERROR:%~nx0] vsperfmon.exe was not found
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