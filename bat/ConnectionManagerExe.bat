set __VSCMD_script_err_count=0
if "%VSCMD_TEST%" NEQ "" goto :test
if "%VSCMD_ARG_CLEAN_ENV%" NEQ "" goto :clean_env

@REM ------------------------------------------------------------------------
:start

if not exist "%VSINSTALLDIR%Common7\IDE\VC\Linux\bin\ConnectionManagerExe" goto :error_setting_path
set "PATH=%PATH%;%VSINSTALLDIR%Common7\IDE\VC\Linux\bin\ConnectionManagerExe"
goto :end

:error_setting_path
exit /B 1

goto :end

@REM ------------------------------------------------------------------------
:test

setlocal

where ConnectionManager.exe
if "%ERRORLEVEL%" NEQ "0" (
    @echo [ERROR:%~nx0] 'where ConnectionManager.exe' failed
    set /A __VSCMD_script_err_count=__VSCMD_script_err_count+1
)

@REM exports the value of _vscmd_script_err_count from the 'setlocal' region
endlocal & set __VSCMD_script_err_count=%__VSCMD_script_err_count%

goto :end

@REM ------------------------------------------------------------------------
:clean_env

@REM this script only modifies PATH, so additional clean-up is not required.

goto :end

@REM ------------------------------------------------------------------------
:end

@REM return value other than 0 if tests failed.
if "%__VSCMD_script_err_count%" NEQ "0" (
   set __VSCMD_script_err_count=
   exit /B 1
)

set __VSCMD_script_err_count=
exit /B 0
