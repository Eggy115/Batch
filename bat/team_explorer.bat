
set __VSCMD_script_err_count=0
if "%VSCMD_TEST%" NEQ "" goto :test
if "%VSCMD_ARG_CLEAN_ENV%" NEQ "" goto :clean_env

@REM ------------------------------------------------------------------------
:start

@REM Add Team Explorer to PATH
set "__team_explorer_path=%DevEnvDir%CommonExtensions\Microsoft\TeamFoundation\Team Explorer"

if NOT EXIST "%__team_explorer_path%" (
    goto :end
)

set "PATH=%__team_explorer_path%;%PATH%"   
goto :end

@REM ------------------------------------------------------------------------
:test

setlocal

@echo [TEST:%~nx0] Testing for tf.exe...
where tf.exe > NUL 2>&1
if "%ERRORLEVEL%" NEQ "0" (
    @echo [ERROR:%~nx0] 'where tf.exe' failed
    set /A __VSCMD_script_err_count=__VSCMD_script_err_count+1
)

@REM exports the value of _vscmd_script_err_count from the 'setlocal' region
endlocal & set __VSCMD_script_err_count=%__VSCMD_script_err_count%

goto :end

@REM ------------------------------------------------------------------------
:clean_env
@REM ******************************************************************
@REM Note: INCLUDE, LIB, LIBPATH, PATH are handled by vsdevcmd.bat
@REM       directly.  No custom clean-up required.
@REM ******************************************************************

goto :end

@REM ------------------------------------------------------------------------
:end
set __team_explorer_path=

@REM return value other than 0 if tests failed.
if "%__VSCMD_script_err_count%" NEQ "0" (
   set __VSCMD_script_err_count=
   exit /B 1
)

set __VSCMD_script_err_count=
exit /B 0
