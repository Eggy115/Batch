
set __netfx_script_errcount=0
if "%VSCMD_TEST%" NEQ "" goto :test
if "%VSCMD_ARG_CLEAN_ENV%" NEQ "" goto :clean_env

@REM -----------------------------------------------------------------------
call :GetNetFxSdkExecutablePath
if "%ERRORLEVEL%" neq "0" set __netfx_script_errcount=1

if /I "%VSCMD_ARG_TGT_ARCH%" == "x86" set "__NETFX_TARGET_DIR=\x86"
if /I "%VSCMD_ARG_TGT_ARCH%" == "x64" set "__NETFX_TARGET_DIR=\x64"
if /I "%VSCMD_ARG_TGT_ARCH%" == "arm" set "__NETFX_TARGET_DIR=\arm"
if /I "%VSCMD_ARG_TGT_ARCH%" == "arm64" set "__NETFX_TARGET_DIR=\arm64"

goto :export_env

@REM -----------------------------------------------------------------------
:GetNetFxSdkExecutablePath
set WindowsSDK_ExecutablePath_x86=
set WindowsSDK_ExecutablePath_x64=
set NETFXSDKDir=

set __netfxsdk_script_arch=X64
if /I "%PROCESSOR_ARCHITECTURE%" == "x86" (
    if not defined PROCESSOR_ARCHITEW6432 set __netfxsdk_script_arch=X86
)
if "%__netfxsdk_script_arch%" == "X86" (
call :GetWindowsSdkExePathHelper HKLM\SOFTWARE > nul 2>&1
if errorlevel 1 call :GetWindowsSdkExePathHelper HKCU\SOFTWARE > nul 2>&1
) else (
call :GetWindowsSdkExePathHelper HKLM\SOFTWARE\Wow6432Node > nul 2>&1
if errorlevel 1 call :GetWindowsSdkExePathHelper HKCU\SOFTWARE\Wow6432Node > nul 2>&1
if errorlevel 1 call :GetWindowsSdkExePathHelper HKLM\SOFTWARE > nul 2>&1
if errorlevel 1 call :GetWindowsSdkExePathHelper HKCU\SOFTWARE > nul 2>&1
)
set __netfxsdk_script_arch=
exit /B 0

@REM -----------------------------------------------------------------------
:GetWindowsSdkExePathHelper
@REM Short-circuit checking for each .NET version if the parent key doesn't even exist
SET "_NetFxSdkRegistryBase=%1\Microsoft\Microsoft SDKs\NETFXSDK"
reg query "%_NetFxSdkRegistryBase%"
if %ERRORLEVEL% == 0 (
    @REM Get .NET 4.8 SDK tools and libs include path
    call :GetNetFxSdkPathsFromRegistryHelper "%_NetFxSdkRegistryBase%\4.8"
    @REM Falls back to get .NET 4.7.2 SDK tools and libs include path
    if errorlevel 1 call :GetNetFxSdkPathsFromRegistryHelper "%_NetFxSdkRegistryBase%\4.7.2"
    @REM Falls back to get .NET 4.7.1 SDK tools and libs include path
    if errorlevel 1 call :GetNetFxSdkPathsFromRegistryHelper "%_NetFxSdkRegistryBase%\4.7.1"
    @REM Falls back to get .NET 4.7 SDK tools and libs include path
    if errorlevel 1 call :GetNetFxSdkPathsFromRegistryHelper "%_NetFxSdkRegistryBase%\4.7"
    @REM Falls back to get .NET 4.6.2 SDK tools and libs include path
    if errorlevel 1 call :GetNetFxSdkPathsFromRegistryHelper "%_NetFxSdkRegistryBase%\4.6.2"
    @REM Falls back to get .NET 4.6.1 SDK tools and libs include path
    if errorlevel 1 call :GetNetFxSdkPathsFromRegistryHelper "%_NetFxSdkRegistryBase%\4.6.1"
    @REM Falls back to get .NET 4.6 SDK tools and libs include path
    if errorlevel 1 call :GetNetFxSdkPathsFromRegistryHelper "%_NetFxSdkRegistryBase%\4.6"
)
SET _NetFxSdkRegistryBase=

@REM Falls back to use .NET 4.5.1 SDK
if "%WindowsSDK_ExecutablePath_x86%"=="" for /F "tokens=1,2*" %%i in ('reg query "%1\Microsoft\Microsoft SDKs\Windows\v8.1A\WinSDK-NetFx40Tools-x86" /v "InstallationFolder"') DO (
    if "%%i"=="InstallationFolder" (
        SET "WindowsSDK_ExecutablePath_x86=%%k"
    )
)

if "%WindowsSDK_ExecutablePath_x64%"=="" for /F "tokens=1,2*" %%i in ('reg query "%1\Microsoft\Microsoft SDKs\Windows\v8.1A\WinSDK-NetFx40Tools-x64" /v "InstallationFolder"') DO (
    if "%%i"=="InstallationFolder" (
        SET "WindowsSDK_ExecutablePath_x64=%%k"
    )
)

if "%WindowsSDK_ExecutablePath_x86%"=="" if "%WindowsSDK_ExecutablePath_x64%"=="" exit /B 1
exit /B 0

@REM -----------------------------------------------------------------------
:GetNetFxSdkPathsFromRegistryHelper
for /F "tokens=1,2*" %%i in ('reg query "%~1\WinSDK-NetFx40Tools-x86" /v "InstallationFolder"') DO (
    if "%%i"=="InstallationFolder" (
        SET "WindowsSDK_ExecutablePath_x86=%%k"
    )
)

for /F "tokens=1,2*" %%i in ('reg query "%~1\WinSDK-NetFx40Tools-x64" /v "InstallationFolder"') DO (
    if "%%i"=="InstallationFolder" (
        SET "WindowsSDK_ExecutablePath_x64=%%k"
    )
)

for /F "tokens=1,2*" %%i in ('reg query "%~1" /v "KitsInstallationFolder"') DO (
    if "%%i"=="KitsInstallationFolder" (
        SET "NETFXSDKDir=%%k"
    )
)

if "%NETFXSDKDir%"=="" exit /B 1
exit /B 0

@REM -----------------------------------------------------------------------
:clean_env
set __netfx_script_errcount=0

set WindowsSDK_ExecutablePath=
set WindowsSDK_ExecutablePath_x86=
set WindowsSDK_ExecutablePath_x64=
set NETFXSDKDir=

goto:end

@REM -----------------------------------------------------------------------
:test
set __netfx_script_errcount=0

if NOT "%NETFXSDKDir%"=="" (
    setlocal
    @echo [TEST:%~nx0] Checking for ildasm.exe...
    where ildasm.exe > NUL 2>&1
    if "%ERRORLEVEL%" NEQ "0" (
        @echo [ERROR:%~nx0] Test 'where ildasm.exe' failed.
        set /A __netfx_script_errcount=__netfx_script_errcount+1
    )

    @echo [TEST:%~nx0] Checking for sn.exe...
    where sn.exe > NUL 2>&1
    if "%ERRORLEVEL%" NEQ "0" (
        @echo [ERROR:%~nx0] Test 'where sn.exe' failed.
        set /A __netfx_script_errcount=__netfx_script_errcount+1
    )
    endlocal & set __netfx_script_errcount=%__netfx_script_errcount%
) else (
    @echo [TEST:%~nx0] .NET FX SDK not installed - skipping test.
)

goto :end

@REM -----------------------------------------------------------------------
:export_env

@REM Skip attempting to set INCLUDE and LIB if NETFXSDKDir was not found.
if "%NETFXSDKDir%" == "" goto :export_bin

if "%__NETFX_TARGET_DIR%" == "" (
    @echo [ERROR:%~nx0] Unknown target architecture '%VSCMD_ARG_TGT_ARCH%'
    set __netfx_script_errcount=1
    goto :end
)

@REM Only add these directories to INCLUDE and LIB, respectively, if they exist.
@REM When this script reaches its final destination, these 'if EXISTS' guards should be
@REM removed.
@REM Use vcvars-specific INCLUDE variable to ensure include ordering is coordinated with msbuild.
if EXIST "%NETFXSDKDir%include\um" set "__VSCMD_NETFX_INCLUDE=%NETFXSDKDir%include\um;%__VSCMD_NETFX_INCLUDE%"
if EXIST "%NETFXSDKDir%lib\um%__NETFX_TARGET_DIR%" set "LIB=%NETFXSDKDir%lib\um%__NETFX_TARGET_DIR%;%LIB%"

:export_bin

if /I "%VSCMD_ARG_HOST_ARCH%" == "x86" goto :export_x86
if /I "%VSCMD_ARG_HOST_ARCH%" == "x64" goto :export_x64

:export_x86
if not "%WindowsSDK_ExecutablePath_x86%" == "" set "PATH=%WindowsSDK_ExecutablePath_x86%;%PATH%"
goto :end

:export_x64
if not "%WindowsSDK_ExecutablePath_x64%" == "" set "PATH=%WindowsSDK_ExecutablePath_x64%;%PATH%"
goto :end

@REM -----------------------------------------------------------------------
:end
set __NETFX_TARGET_DIR=

if "%__netfx_script_errcount%" NEQ "0" (
    set __netfx_script_errcount=
    exit /B 1
)

set __netfx_script_errcount=
exit /B 0



