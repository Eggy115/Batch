
if "%VSCMD_TEST%" NEQ "" goto :test
if "%VSCMD_ARG_CLEAN_ENV%" NEQ "" goto :clean_env

@REM vcvars140.bat
if "%__VCVARS_VERSION%" NEQ "14.0" (
    if "%VSCMD_DEBUG%" GEQ "1" @echo [DEBUG:%~nx0] skipping init : VCVARS_USER_VERSION = "%VCVARS_USER_VERSION%"
    exit /B 0
)

@REM ------------------------------------------------------------------------
:check_platform

if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:%~nx0] Checking architecture { host , tgt } : { %VSCMD_ARG_HOST_ARCH% , %VSCMD_ARG_TGT_ARCH% }

set __VCVARS_APP_DIR=
if /I "%VSCMD_ARG_APP_PLAT%" == "UWP" (
    set __VCVARS_APP_DIR=store
) else if /I "%VSCMD_ARG_APP_PLAT%" == "OneCore" (
    set __VCVARS_APP_DIR=onecore
)

@REM Generate folder paths
if /I "%VSCMD_ARG_HOST_ARCH%" == "x86" (
    set __VCVARS_HOST_DIR=x86
    set __VCVARS_HOST_NATIVEDIR=
)
if /I "%VSCMD_ARG_HOST_ARCH%" == "x64" (
    set __VCVARS_HOST_DIR=amd64
    set __VCVARS_HOST_NATIVEDIR=amd64
)

if /I "%VSCMD_ARG_TGT_ARCH%" == "x86" set __VCVARS_TARGET_DIR=x86
if /I "%VSCMD_ARG_TGT_ARCH%" == "x64" set __VCVARS_TARGET_DIR=amd64
if /I "%VSCMD_ARG_TGT_ARCH%" == "arm" set __VCVARS_TARGET_DIR=arm

if "%__VCVARS_HOST_DIR%" == "" (
	@echo [ERROR:%~nx0] Unknown host architecture '%VSCMD_ARG_HOST_ARCH%'
	set __VCVARS_SCRIPT_ERROR=1
	goto :end
)

if "%__VCVARS_TARGET_DIR%" == "" (
	@echo [ERROR:%~nx0] Unknown target architecture '%VSCMD_ARG_TGT_ARCH%'
	set __VCVARS_SCRIPT_ERROR=1
	goto :end
)

@REM Binaries directory depends on architecture
@REM VC\bin for x86
@REM VC\bin\<host>_<tgt> for cross tools,
@REM VC\Bin\amd64 for x64-native tools.
if "%__VCVARS_HOST_DIR%" NEQ "%__VCVARS_TARGET_DIR%" (
    set "__VCVARS_BIN_DIR=\%__VCVARS_HOST_DIR%_%__VCVARS_TARGET_DIR%"
) else if "%__VCVARS_HOST_DIR%" == "x86" (
    @REM x86 is a special case in that it does not have an architecture-specific directory.
    set __VCVARS_BIN_DIR=
) else (
    set "__VCVARS_BIN_DIR=\%__VCVARS_HOST_DIR%"
)

@REM Lib directory depends on architecture
@REM VC\lib\[store] for x86
@REM VC\lib\[store]\amd64 for amd64
@REM VC\lib\[store]\arm for ARM

set __VCVARS_LIB_DIR=
if "%__VCVARS_APP_DIR%" NEQ "" set "__VCVARS_LIB_DIR=\%__VCVARS_APP_DIR%"
if "%__VCVARS_TARGET_DIR%" == "amd64" set "__VCVARS_LIB_DIR=%__VCVARS_LIB_DIR%\amd64"
if "%__VCVARS_TARGET_DIR%" == "arm" set "__VCVARS_LIB_DIR=%__VCVARS_LIB_DIR%\arm"

goto :vcvars_environment

@REM ------------------------------------------------------------------------
:vcvars_environment

if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:%~nx0] Checking for v140 tools in the registry.

@REM Check for HKLM\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\SxS\VC7@14.0 for VCINSTALLDIR path
if "%VSCMD_DEBUG%" GEQ "2" (
    call :call_get_vcinstalldir_140_debug
) else (
    call :call_get_vcinstalldir_140
)

if "%__VCVARS_DIR_REG_140%" == "" (
    @echo [ERROR:%~nx0] VC++ 14.0 Toolset Installation was not found. Init did not complete successfully.
    exit /B 1
)

if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:%~nx0] Setting VCInstallDir = "%__VCVARS_DIR_REG_140%"
set "VCInstallDir=%__VCVARS_DIR_REG_140%"
set "VCIDEInstallDir=%VCINSTALLDIR%"

goto :export_env

@REM ------------------------------------------------------------------------

@REM We have two versions of :call_get_vcinstalldir_140[_debug] to have an option that
@REM does not suppress reg query errors from showing up in the console output.
@REM This is specifically to support trace level diagnostic debugging and is
@REM "off by default"

:call_get_vcinstalldir_140
call :call_get_vcinstalldir_140_reg HKLM\SOFTWARE\WOW6432Node > NUL 2>&1
if "%ERRORLEVEL%" == "1" call :call_get_vcinstalldir_140_reg HKLM\SOFTWARE > NUL 2>&1
if "%ERRORLEVEL%" == "1" exit /B 1
exit /B 0

:call_get_vcinstalldir_140_debug
@REM This is only called if VSCMD_DEBUG >= 2, and does not route STDOUT/STDERR
@REM to NUL.

if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:%~nx0] Checking registry without suppressions (in debug mode).

call :call_get_vcinstalldir_140_reg HKLM\SOFTWARE\WOW6432Node
if "%ERRORLEVEL%" == "1" call :call_get_vcinstalldir_140_reg HKLM\SOFTWARE
if "%ERRORLEVEL%" == "1" exit /B 1
exit /B 0

@REM ------------------------------------------------------------------------
:call_get_vcinstalldir_140_reg

if "%1" == "" (
    @echo [ERROR:%~nx0] :call_get_vcinstalldir_140 called without reg key argument
    exit /B 1
)

set __VCVARS_DIR_REG_140=
for /F "tokens=1,2*" %%i in ('reg query "%1\Microsoft\VisualStudio\SxS\VC7" /v "14.0"') DO (
    if "%%i"=="14.0" (
        set "__VCVARS_DIR_REG_140=%%~k"
    )
)

if "%__VCVARS_DIR_REG_140%" == "" exit /B 1

if "%VSCMD_DEBUG%" GEQ "2" (
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:%~nx0] VC++ 14.0 Toolset Location is "%__VCVARS_DIR_REG_140%"
)
exit /B 0

@REM ------------------------------------------------------------------------
:test

set __VSCMD_TEST_FailCount=0

setlocal

@REM -- check for cl.exe on the path --
@echo [TEST:%~nx0] Checking for cl.exe...
where cl.exe > NUL 2>&1
if "%ERRORLEVEL%" NEQ "0" (
    @echo [ERROR:%~nx0] 'where cl.exe' failed
    set /A __VSCMD_TEST_FailCount=__VSCMD_TEST_FailCount+1
)

@REM -- Check for dumpbin.exe on the path.
@REM -- Verifies tools that only exist in native targeting directories
@REM -- are also on the path (for Cross Targeting scenarios)
@echo [TEST:%~nx0] Checking for dumpbin.exe...
where dumpbin.exe > NUL 2>&1
if "%ERRORLEVEL%" NEQ "0" (
    @echo [ERROR:%~nx0] 'where dumpbin.exe' failed
    set /A __VSCMD_TEST_FailCount=__VSCMD_TEST_FailCount+1
)

@REM -- check for msvcrt.lib in LIB --
@echo [TEST:%~nx0] Checking for msvcrt.lib in LIB...
set TEST_LIB=%LIB%
call :test_lib
if "%ERRORLEVEL%" NEQ "0" (
    @echo [ERROR:%~nx0] could not find 'msvcrt.lib' in LIB
    set /A __VSCMD_TEST_FailCount=__VSCMD_TEST_FailCount+1
)

@echo [TEST:%~nx0] Checking for vcruntime.h in INCLUDE...
@REM -- check for vcruntime.h in INCLUDE --
set TEST_INCLUDE=%INCLUDE%
call :test_include
if "%ERRORLEVEL%" NEQ "0" (
    @echo [ERROR:%~nx0] could not find 'vcruntime.h' in INCLUDE
    set /A __VSCMD_TEST_FailCount=__VSCMD_TEST_FailCount+1
)

@REM end local execution and export __vscmd_test_failcount out of the 'setlocal' region
endlocal & set __VSCMD_Test_FailCount=%__VSCMD_TEST_FailCount%

:test_end
if "%__VSCMD_TEST_FailCount%" NEQ "0" (
    set __VSCMD_TEST_FailCount=
    exit /B 1
)

exit /B 0

@REM ------------------------------------------------------------------------
:test_lib

if "%LIB%"=="" (
    @echo [ERROR:%~nx0] LIB environment variable was empty
    exit /B 1
)

for /F "tokens=1* delims=;" %%A in ("%TEST_LIB%") do (

   if EXIST "%%A\msvcrt.lib" (
      exit /B 0
   )

   set TEST_LIB=%%B
   goto :test_lib
)

exit /B 1

@REM ------------------------------------------------------------------------
:test_include
if "%INCLUDE%"=="" (
    @echo [ERROR:%~nx0] INCLUDE environment variable was empty
    exit /B 1
)

for /F "tokens=1* delims=;" %%A in ("%TEST_INCLUDE%") do (

   if EXIST "%%A\vcruntime.h" (
      exit /B 0
   )

   set TEST_INCLUDE=%%B
   goto :test_include
)

exit /B 1

@REM return value other than 0 if tests failed.
if "%__VSCMD_TEST_FailCount%" NEQ "0" (
   set __VSCMD_Test_FailCount=
   exit /B 1
)

set __VSCMD_Test_FailCount=
exit /B 0

:clean_env

set VCINSTALLDIR=
set VCToolsInstallDir=
set VCToolsRedistDir=
set VCIDEInstallDir=
set Platform=
set CommandPromptType=
set PreferredToolArchitecture=
set VCTargetsUnderVCInstall=
set ExtensionSdkDir=

goto :end

@REM ------------------------------------------------------------------------
:export_env

if "%VSCMD_VCVARSALL_INIT%" NEQ "" (
    set Platform=%VSCMD_ARG_TGT_ARCH%
)
if /I "%VSCMD_ARG_HOST_ARCH%" NEQ "%VSCMD_ARG_TGT_ARCH%" (
    set CommandPromptType=Cross
    if /I "%VSCMD_ARG_HOST_ARCH%"=="x64" set PreferredToolArchitecture=x64
) else (
    set CommandPromptType=Native
    set PreferredToolArchitecture=
)

@REM Check for ExtensionSdkDir
@if exist "%ProgramFiles%\Microsoft SDKs\Windows Kits\10\ExtensionSDKs" set ExtensionSdkDir=%ProgramFiles%\Microsoft SDKs\Windows Kits\10\ExtensionSDKs
@if exist "%ProgramFiles(x86)%\Microsoft SDKs\Windows Kits\10\ExtensionSDKs" set ExtensionSdkDir=%ProgramFiles(x86)%\Microsoft SDKs\Windows Kits\10\ExtensionSDKs

@REM Add VCPackages
call :add_to_path_optional "%VCIDEInstallDir%VCPackages"

@REM Add MSVC
set __VCVARS_TOOLS_VERSION=14.0

if exist "%VCINSTALLDIR%bin" (
    set "VCToolsInstallDir=%VCINSTALLDIR%"
) else (
    set VCToolsInstallDir=
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:%~nx0] Could not find VC++ tools version "%__VCVARS_TOOLS_VERSION%" under "%VCINSTALLDIR%bin".
    goto :end
)

if exist "%VCINSTALLDIR%Redist" (
    set "VCToolsRedistDir=%VCINSTALLDIR%Redist\"
) else (
    set VCToolsRedistDir=
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:%~nx0] Could not find VC++ tools version "%__VCVARS_TOOLS_VERSION%" under "%VCINSTALLDIR%Redist".
    goto :end
)

@REM for cross compiler scenarios, add the native host compiler toolset directory to PATH
@REM before adding the cross compiler directory.
if /I "%CommandPromptType%"=="Cross" (
    if "%__VCVARS_HOST_NATIVEDIR%" == "" (
        call :add_to_path_optional "%VCToolsInstallDir%bin
    ) else (
        call :add_to_path_optional "%VCToolsInstallDir%bin\%__VCVARS_HOST_NATIVEDIR%"
    )
)

call :add_to_path_optional "%VCToolsInstallDir%bin%__VCVARS_BIN_DIR%"
call :add_to_include_optional "%VCToolsInstallDir%ATLMFC\include"
call :add_to_include_optional "%VCToolsInstallDir%include"

@REM Set LIB based upon target platform
call :add_to_lib_optional "%VCToolsInstallDir%lib%__VCVARS_LIB_DIR%"
call :add_to_libpath_optional "%VCToolsInstallDir%lib\store\references"

if /I "%VSCMD_ARG_APP_PLAT%"=="Desktop" (
    call :add_to_lib_optional "%VCToolsInstallDir%ATLMFC\lib%__VCVARS_LIB_DIR%"
    call :add_to_libpath_optional "%VCToolsInstallDir%lib%__VCVARS_LIB_DIR%"
    call :add_to_libpath_optional "%VCToolsInstallDir%ATLMFC\lib%__VCVARS_LIB_DIR%"
)

@REM ... set _checkWin81 so it will not match if the Windows 8.1 SDK has been selected/specified.
set "__checkWin81=%WindowsSdkDir:8.1=FOUND%"
if "%__checkWin81%" NEQ	"%WindowsSdkDir%" goto :check_win81_app_platform

@REM Windows 10 SDK only past this point
if /I "%VSCMD_ARG_APP_PLAT%"=="UWP" (
    call :add_to_libpath_optional "%ExtensionSDKDir%\Microsoft.VCLibs\14.0\References\CommonConfiguration\neutral"
)

goto :end

@REM ------------------------------------------------------------------------
:add_to_path_optional
if exist "%~1" (
    set "PATH=%~1;%PATH%"
    exit /B 0
) else (
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:%~nx0] Could not add directory to PATH: "%~1"
    exit /B 1
)

@REM ------------------------------------------------------------------------
:add_to_lib_optional
if exist "%~1" (
    set "LIB=%~1;%LIB%"
    exit /B 0
) else (
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:%~nx0] Could not add directory to LIB: "%~1"
    exit /B 1
)

@REM ------------------------------------------------------------------------
:add_to_libpath_optional
if exist "%~1" (
    set "LIBPATH=%~1;%LIBPATH%"
    exit /B 0
) else (
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:%~nx0] Could not add directory to LIBPATH: "%~1"
    exit /B 1
)

@REM ------------------------------------------------------------------------
:add_to_include_optional
if exist "%~1" (
@REM Use vcvars-specific INCLUDE variable to ensure include ordering is coordinated with msbuild.
    set "__VSCMD_VCVARS_INCLUDE=%~1;%__VSCMD_VCVARS_INCLUDE%"
    exit /B 0
) else (
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:%~nx0] Could not add directory to INCLUDE: "%~1"
    exit /B 1
)

@REM ------------------------------------------------------------------------
:check_win81_app_platform

if /I "%VSCMD_ARG_APP_PLAT%"=="UWP" goto :report_win81_app_platform_error
if /I "%VSCMD_ARG_APP_PLAT%"=="OneCore" goto :report_win81_app_platform_error

goto :end

:report_win81_app_platform_error
@echo [ERROR:%~nx0] The %VSCMD_ARG_APP_PLAT% Application Platform requires a Windows 10 SDK.
@echo [ERROR:%~nx0] WindowsSdkDir = "%WindowsSdkDir%"
set __VCVARS_SCRIPT_ERROR=1


@REM ------------------------------------------------------------------------
:report_architecture_error

set __VCVARS_SCRIPT_ERROR=1
@echo [ERROR:%~nx0] host/target architecture is not supported : { %VSCMD_ARG_HOST_ARCH% , %VSCMD_ARG_TGT_ARCH% }
goto :end


@REM ------------------------------------------------------------------------
:end
set __VCVARS_HOST_DIR=
set __VCVARS_HOST_NATIVEDIR=
set __VCVARS_TARGET_DIR=
set __VCVARS_BIN_DIR=
set __VCVARS_LIB_DIR=
set __VCVARS_TOOLS_VERSION=
set __VCVARS_DEFAULT_CONFIG_FILE=
set __VCVARS_APP_DIR=
set __VCVARS_DIR_REG_140=

set __checkWin81=

if "%__VCVARS_SCRIPT_ERROR%" NEQ "" (
   set __VCVARS_SCRIPT_ERROR=
   exit /B 1
)
exit /B 0