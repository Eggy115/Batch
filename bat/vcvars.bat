if "%__VSCMD_INTERNAL_INIT_STATE%"=="help" goto :print_help
if "%__VSCMD_INTERNAL_INIT_STATE%"=="test" goto :test
if "%__VSCMD_INTERNAL_INIT_STATE%"=="clean" goto :clean_env
if "%__VSCMD_INTERNAL_INIT_STATE%"=="export" goto :export_parse_variables
if "%__VSCMD_INTERNAL_INIT_STATE%"=="parse" goto :parse_arg_inner  %1 %2

@REM ------------------------------------------------------------------------
@REM Support user-specified version of the Visual C++ Toolset to initialize.
@REM Initialization of the environment for different VC++ versions are
@REM mutually exclusive, so we use this script to invoke the correct script
@REM based upon user-specified versioning.
@REM The latest/default toolset is read from :
@REM    * Auxiliary\Build\Microsoft.VCToolsVersion.default.txt
@REM The latest/default redist directory is read from :
@REM    * Auxiliary\Build\Microsoft.VCRedistVersion.default.txt

if "%VSCMD_ARG_VCVARS_VER%" NEQ "" (
    set "__VCVARS_VERSION=%VSCMD_ARG_VCVARS_VER%"
) else if "%VCVARS_USER_VERSION%" NEQ "" (
    if "%VSCMD_DEBUG%" GEQ "1" @echo [DEBUG:ext\%~nx0] VCVARS_USER_VERSION = "%VCVARS_USER_VERSION%"
    set "__VCVARS_VERSION=%VCVARS_USER_VERSION%"
) else if "%VCToolsVersion%" NEQ "" (
    if "%VSCMD_DEBUG%" GEQ "1" @echo [DEBUG:ext\%~nx0] VCToolsVersion = "%VCToolsVersion%"
    set "__VCVARS_VERSION=%VCToolsVersion%"
    set "__VSCMD_PREINIT_VCToolsVersion=%VCToolsVersion%"
)

@REM Support the VS 2015 Visual C++ Toolset
if "%__VCVARS_VERSION%" == "14.0" (
    goto :vcvars140_version
)

@REM If VCVARS_VERSION was not specified, then default initialize the environment
if "%__VCVARS_VERSION%" == "" (
    goto :check_platform
)

:check_vcvars_ver_exists
@REM If we've reached this point, we've detected an override of the toolset version.

@REM Check if full version was provided and the target directory exists. If so, we can proceed to environment setup.
if EXIST "%VSINSTALLDIR%\VC\Tools\MSVC\%__VCVARS_VERSION%" (
    goto :check_platform
)

@REM a. Check for SxS toolset version If it is in this form (MM.mm.VV.vv), then we need to look-up
@REM the toolset version number from the SxS toolset auxiliary files/directory:
@REM   Auxiliary\Build\MM.mm.VV.vv\Microsoft.VCToolsVersion.MM.mm.VV.vv.txt
@REM If the SxS toolset is not found, then fallback to attempting to use the latest toolset matching
@REM   Tools\MSVC\MM.vv.* (behave the same as if -vcvars_ver=MM.mm)
@REM b. Check for MAJOR.MINOR.VERSION formatted string. If it is
@REM in this form, we need an exact match only and should ERROR otherwise.  We'll check
@REM for this by looking for two '.' in the version number as a first approximation.
for /F "tokens=1,2,3,* delims=." %%a in ("%__VCVARS_VERSION%") DO (

   if "%%d" NEQ "" (
       if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Looking up MSVC SxS Toolset version 'VC\Auxiliary\Build\%__VCVARS_VERSION%'

       if NOT EXIST "%VSINSTALLDIR%\VC\Auxiliary\Build\%__VCVARS_VERSION%\Microsoft.VCToolsVersion.%__VCVARS_VERSION%.txt" (
           @REM emit warning that 'MM.mm.VV.vv' version was not found and fallback to discovery of the latest toolset
           @REM of version 'MM.mm'.
           @echo [WARN:%~nx0] SxS version %__VCVARS_VERSION% was not present/installed. Attempting fallback selection of toolset 'VC\Tools\MSVC\%%a.%%b.*'
           set "__VCVARS_VERSION=%%a.%%b"
           goto :check_vcvars_ver_major_minor
       )
       goto :extract_vcvars_ver_sxs
   )
   if "%%c" NEQ "" (
       @echo [ERROR:%~nx0] Version '%__VCVARS_VERSION%' is not valid; directory does not exist
       set __VCVARS_SCRIPT_ERROR=1
       goto :end
   )
)

:check_vcvars_ver_major_minor

@REM Check if a partial version was provided (e.g. MAJOR.MINOR only).  In this case,
@REM select the first directory we find that matches that prefix.
set __VCVARS_VER_TMP=
setlocal enableDelayedExpansion

@REM ensure that no unexpected options intefere with the 'dir' command.
set DIRCMD=

for /F %%a IN ('dir "%VSINSTALLDIR%\VC\Tools\MSVC\" /b /ad-h /o-n') DO (
    set __VCVARS_DIR=%%a
    set __VCVARS_DIR_REP=!__VCVARS_DIR:%__VCVARS_VERSION%=_vcvars_found!
    if "!__VCVARS_DIR!" NEQ "!__VCVARS_DIR_REP!" (
        set "__VCVARS_VER_TMP=!__VCVARS_DIR!"
        goto :check_vcvars_ver_exists_end
    )
)
:check_vcvars_ver_exists_end 

endlocal & set __VCVARS_VER_TMP=%__VCVARS_VER_TMP%

@REM go to :check_platform if a version match was found
if "%__VCVARS_VER_TMP%" NEQ "" (
    set "__VCVARS_VERSION=%__VCVARS_VER_TMP%"
    goto :check_platform
)

@echo [ERROR:%~nx0] Toolset directory for version '%__VCVARS_VERSION%' was not found.
set __VCVARS_SCRIPT_ERROR=1
goto :end

:extract_vcvars_ver_sxs
@REM At this point, __VCVARS_VERSION is of the form MM.mm.VV.vv
@REM where : MM = toolset major ver
@REM         mm = toolset minor ver
@REM         VV = VS major ver
@REM         vv = VS minor ver
@REM we expect to see a directory MM.mm.VV.vv under VC\Auxiliary\Build otherwise, error.
set __VCVARS_SXS_FILE=%VSINSTALLDIR%\VC\Auxiliary\Build\%__VCVARS_VERSION%\Microsoft.VCToolsVersion.%__VCVARS_VERSION%.txt

@REM Use 'type' with double quotes to escape parentheses.
for /F %%A in ('type "%__VCVARS_SXS_FILE%"') do (
    set "__VCVARS_SXS_VERSION=%%A"
)

if "%VSCMD_DEBUG%" GEQ "1" @echo [DEBUG:ext\%~nx0] MSVC SxS Toolset in 'VC\Auxiliary\Build\%__VCVARS_VERSION%' maps to toolset version 'VC\Tools\MSVC\%__VCVARS_SXS_VERSION%'
if exist "%VSINSTALLDIR%\VC\Tools\MSVC\%__VCVARS_SXS_VERSION%" (
    set "__VCVARS_VERSION=%__VCVARS_SXS_VERSION%"
    goto :check_platform
) 

@echo [ERROR:%~nx0] Toolset directory for version '%__VCVARS_SXS_VERSION%' from '%__VCVARS_SXS_FILE%' was not found.
set __VCVARS_SCRIPT_ERROR=1
goto :end

@REM ------------------------------------------------------------------------
:check_platform

if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Checking architecture { host , tgt } : { %VSCMD_ARG_HOST_ARCH% , %VSCMD_ARG_TGT_ARCH% }

call :detect_env_overrides

@REM Generate folder paths
if /I "%VSCMD_ARG_HOST_ARCH%" == "x86" (
    set __VCVARS_HOST_DIR=\HostX86
    set __VCVARS_HOST_NATIVEDIR=\x86
)
if /I "%VSCMD_ARG_HOST_ARCH%" == "x64" (
    set __VCVARS_HOST_DIR=\HostX64
    set __VCVARS_HOST_NATIVEDIR=\x64
)
if /I "%VSCMD_ARG_HOST_ARCH%" == "arm" (
    set __VCVARS_HOST_DIR=\HostARM
    set __VCVARS_HOST_NATIVEDIR=\arm
)
if /I "%VSCMD_ARG_HOST_ARCH%" == "arm64" (
    set __VCVARS_HOST_DIR=\HostARM64
    set __VCVARS_HOST_NATIVEDIR=\arm64
)

if /I "%VSCMD_ARG_TGT_ARCH%" == "x86" set __VCVARS_TARGET_DIR=\x86
if /I "%VSCMD_ARG_TGT_ARCH%" == "x64" set __VCVARS_TARGET_DIR=\x64
if /I "%VSCMD_ARG_TGT_ARCH%" == "arm" set __VCVARS_TARGET_DIR=\ARM
if /I "%VSCMD_ARG_TGT_ARCH%" == "arm64" set __VCVARS_TARGET_DIR=\ARM64
if /I "%VSCMD_ARG_VCVARS_SPECTRE%" == "spectre" set __VCVARS_SPECTRE_DIR=\spectre

if "%__VCVARS_HOST_DIR%" == "" (
    @echo [ERROR:%~nx0] Unknown host architecture '%VSCMD_ARG_HOST_ARCH%'
    set __VCVARS_SCRIPT_ERROR=1
    goto :end
)

if "%VSCMD_ARG_VCVARS_SPECTRE%" NEQ "" (
    if "%VSCMD_ARG_VCVARS_SPECTRE%" NEQ "spectre" (
        @echo [ERROR:%~nx0] Unknown  /vcvars_spectre option '%VSCMD_ARG_VCVARS_SPECTRE%'
        set __VCVARS_SCRIPT_ERROR=1
        goto :end
    )
)

if "%__VCVARS_TARGET_DIR%" == "" (
    @echo [ERROR:%~nx0] Unknown target architecture '%VSCMD_ARG_TGT_ARCH%'
    set __VCVARS_SCRIPT_ERROR=1
    goto :end
)

set "__VCVARS_BIN_DIR=%__VCVARS_HOST_DIR%%__VCVARS_TARGET_DIR%"
set "__VCVARS_LIB_DIR=%__VCVARS_TARGET_DIR%"

goto :vcvars_environment

@REM ------------------------------------------------------------------------
:detect_env_overrides

set "__VCVARS_NATIVE_BIN_OVERRIDE="
set "__VCVARS_BIN_OVERRIDE="
set "__VCVARS_VC_LIB_DESKTOP_OVERRIDE="
set "__VCVARS_VC_LIB_STORE_OVERRIDE="
set "__VCVARS_VC_LIB_ONECORE_OVERRIDE="
set "__VCVARS_ATL_LIB_OVERRIDE="
set "__VCVARS_IFC_PATH_OVERRIDE="
set "__VCVARS_VC_INCLUDE_OVERRIDE="
set "__VCVARS_VS_INCLUDE_OVERRIDE="
set "__VCVARS_ATLMFC_INCLUDE_OVERRIDE="
set "__VCVARS_NO_OVERRIDE="

set "VCLIB_GENERAL_OVERRIDE="

@REM -- Setting binary path overrides --
@REM Set binary overrides for x86 host
if /I "%VSCMD_ARG_HOST_ARCH%" == "x86" (
    if "%VC_ExecutablePath_x86_x86%" NEQ "" (
        set "__VCVARS_NATIVE_BIN_OVERRIDE=%VC_ExecutablePath_x86_x86%"
    )

    if /I "%VSCMD_ARG_TGT_ARCH%" == "x86" (
        if "%VC_ExecutablePath_x86_x86%" NEQ "" (
            set "__VCVARS_BIN_OVERRIDE=%VC_ExecutablePath_x86_x86%"
        )
    )

    if /I "%VSCMD_ARG_TGT_ARCH%" == "x64" (
        if "%VC_ExecutablePath_x86_x64%" NEQ "" (
            set "__VCVARS_BIN_OVERRIDE=%VC_ExecutablePath_x86_x64%"
        )
    )

    if /I "%VSCMD_ARG_TGT_ARCH%" == "ARM" (
        if "%VC_ExecutablePath_x86_ARM%" NEQ "" (
            set "__VCVARS_BIN_OVERRIDE=%VC_ExecutablePath_x86_ARM%"
        )
    )

    if /I "%VSCMD_ARG_TGT_ARCH%" == "ARM64" (
        if "%VC_ExecutablePath_x86_ARM64%" NEQ "" (
            set "__VCVARS_BIN_OVERRIDE=%VC_ExecutablePath_x86_ARM64%"
        )
    )
)

@REM Set binary overrides for x64 host
if /I "%VSCMD_ARG_HOST_ARCH%" == "x64" (
    if "%VC_ExecutablePath_x64_x64%" NEQ "" (
        set "__VCVARS_NATIVE_BIN_OVERRIDE=%VC_ExecutablePath_x64_x64%"
    )

    if /I "%VSCMD_ARG_TGT_ARCH%" == "x86" (
        if "%VC_ExecutablePath_x64_x86%" NEQ "" (
            set "__VCVARS_BIN_OVERRIDE=%VC_ExecutablePath_x64_x86%"
        )
    )

    if /I "%VSCMD_ARG_TGT_ARCH%" == "x64" (
        if "%VC_ExecutablePath_x64_x64%" NEQ "" (
            set "__VCVARS_BIN_OVERRIDE=%VC_ExecutablePath_x64_x64%"
        )
    )

    if /I "%VSCMD_ARG_TGT_ARCH%" == "ARM" (
        if "%VC_ExecutablePath_x64_ARM%" NEQ "" (
            set "__VCVARS_BIN_OVERRIDE=%VC_ExecutablePath_x64_ARM%"
        )
    )

    if /I "%VSCMD_ARG_TGT_ARCH%" == "ARM64" (
        if "%VC_ExecutablePath_x64_ARM64%" NEQ "" (
            set "__VCVARS_BIN_OVERRIDE=%VC_ExecutablePath_x64_ARM64%"
        )
    )
)

@REM Set binary overrides for ARM host
if /I "%VSCMD_ARG_HOST_ARCH%" == "ARM" (
    if "%VC_ExecutablePath_ARM_ARM%" NEQ "" (
        set "__VCVARS_NATIVE_BIN_OVERRIDE=%VC_ExecutablePath_ARM_ARM%"
    )

    if /I "%VSCMD_ARG_TGT_ARCH%" == "x86" (
        if "%VC_ExecutablePath_ARM_x86%" NEQ "" (
            set "__VCVARS_BIN_OVERRIDE=%VC_ExecutablePath_ARM_x86%"
        )
    )

    if /I "%VSCMD_ARG_TGT_ARCH%" == "x64" (
        if "%VC_ExecutablePath_ARM_x64%" NEQ "" (
            set "__VCVARS_BIN_OVERRIDE=%VC_ExecutablePath_ARM_x64%"
        )
    )

    if /I "%VSCMD_ARG_TGT_ARCH%" == "ARM" (
        if "%VC_ExecutablePath_ARM_ARM%" NEQ "" (
            set "__VCVARS_BIN_OVERRIDE=%VC_ExecutablePath_ARM_ARM%"
        )
    )

    if /I "%VSCMD_ARG_TGT_ARCH%" == "ARM64" (
        if "%VC_ExecutablePath_ARM_ARM64%" NEQ "" (
            set "__VCVARS_BIN_OVERRIDE=%VC_ExecutablePath_ARM_ARM64%"
        )
    )
)

@REM -- Setting library path overrides --
@REM Set library overrides for x86 target
if /I "%VSCMD_ARG_TGT_ARCH%" == "x86" (
    if "%VC_LibraryPath_VC_x86%" NEQ "" (
         set "VCLIB_GENERAL_OVERRIDE=%VC_LibraryPath_VC_x86%"
    )

    if /I "%VSCMD_ARG_VCVARS_SPECTRE%" == "spectre" (
        if "%VC_LibraryPath_VC_x86_Desktop%" NEQ "" (
             set "__VCVARS_VC_LIB_DESKTOP_OVERRIDE=%VC_LibraryPath_VC_x86_Desktop%"
        )

        if "%VC_LibraryPath_VC_x86_Store%" NEQ "" (
             set "__VCVARS_VC_LIB_STORE_OVERRIDE=%VC_LibraryPath_VC_x86_Store%"
        )

        if "%VC_LibraryPath_VC_x86_OneCore%" NEQ "" (
             set "__VCVARS_VC_LIB_ONECORE_OVERRIDE=%VC_LibraryPath_VC_x86_OneCore%"
        )

        if "%VC_LibraryPath_ATL_x86%" NEQ "" (
             set "__VCVARS_ATL_LIB_OVERRIDE=%VC_LibraryPath_ATL_x86%"
        )
    ) else (
        if "%VC_LibraryPath_VC_x86_Desktop_spectre%" NEQ "" (
             set "__VCVARS_VC_LIB_DESKTOP_OVERRIDE=%VC_LibraryPath_VC_x86_Desktop_spectre%"
        )

        if "%VC_LibraryPath_VC_x86_OneCore_spectre%" NEQ "" (
             set "__VCVARS_VC_LIB_ONECORE_OVERRIDE=%VC_LibraryPath_VC_x86_OneCore_spectre%"
        )

        if "%VC_LibraryPath_ATL_x86_spectre%" NEQ "" (
             set "__VCVARS_ATL_LIB_OVERRIDE=%VC_LibraryPath_ATL_x86_spectre%"
        )
    )
)

@REM Set overrides for x64 target
if /I "%VSCMD_ARG_TGT_ARCH%" == "x64" (
    if "%VC_LibraryPath_VC_x64%" NEQ "" (
         set "VCLIB_GENERAL_OVERRIDE=%VC_LibraryPath_VC_x64%"
    )

    if /I "%VSCMD_ARG_VCVARS_SPECTRE%" == "spectre" (
        if "%VC_LibraryPath_VC_x64_Desktop%" NEQ "" (
             set "__VCVARS_VC_LIB_DESKTOP_OVERRIDE=%VC_LibraryPath_VC_x64_Desktop%"
        )

        if "%VC_LibraryPath_VC_x64_Store%" NEQ "" (
             set "__VCVARS_VC_LIB_STORE_OVERRIDE=%VC_LibraryPath_VC_x64_Store%"
        )

        if "%VC_LibraryPath_VC_x64_OneCore%" NEQ "" (
             set "__VCVARS_VC_LIB_ONECORE_OVERRIDE=%VC_LibraryPath_VC_x64_OneCore%"
        )

        if "%VC_LibraryPath_ATL_x64%" NEQ "" (
             set "__VCVARS_ATL_LIB_OVERRIDE=%VC_LibraryPath_ATL_x64%"
        )
    ) else (
        if "%VC_LibraryPath_VC_x64_Desktop_spectre%" NEQ "" (
             set "__VCVARS_VC_LIB_DESKTOP_OVERRIDE=%VC_LibraryPath_VC_x64_Desktop_spectre%"
        )

        if "%VC_LibraryPath_VC_x64_OneCore_spectre%" NEQ "" (
             set "__VCVARS_VC_LIB_ONECORE_OVERRIDE=%VC_LibraryPath_VC_x64_OneCore_spectre%"
        )

        if "%VC_LibraryPath_ATL_x64_spectre%" NEQ "" (
             set "__VCVARS_ATL_LIB_OVERRIDE=%VC_LibraryPath_ATL_x64_spectre%"
        )
    )
)

@REM Set overrides for ARM target
if /I "%VSCMD_ARG_TGT_ARCH%" == "ARM" (
    if "%VC_LibraryPath_VC_ARM%" NEQ "" (
         set "VCLIB_GENERAL_OVERRIDE=%VC_LibraryPath_VC_ARM%"
    )

    if /I "%VSCMD_ARG_VCVARS_SPECTRE%" == "spectre" (
        if "%VC_LibraryPath_VC_ARM_Desktop%" NEQ "" (
             set "__VCVARS_VC_LIB_DESKTOP_OVERRIDE=%VC_LibraryPath_VC_ARM_Desktop%"
        )

        if "%VC_LibraryPath_VC_ARM_Store%" NEQ "" (
             set "__VCVARS_VC_LIB_STORE_OVERRIDE=%VC_LibraryPath_VC_ARM_Store%"
        )

        if "%VC_LibraryPath_VC_ARM_OneCore%" NEQ "" (
             set "__VCVARS_VC_LIB_ONECORE_OVERRIDE=%VC_LibraryPath_VC_ARM_OneCore%"
        )

        if "%VC_LibraryPath_ATL_ARM%" NEQ "" (
             set "__VCVARS_ATL_LIB_OVERRIDE=%VC_LibraryPath_ATL_ARM%"
        )
    ) else (
        if "%VC_LibraryPath_VC_ARM_Desktop_spectre%" NEQ "" (
             set "__VCVARS_VC_LIB_DESKTOP_OVERRIDE=%VC_LibraryPath_VC_ARM_Desktop_spectre%"
        )

        if "%VC_LibraryPath_VC_ARM_OneCore_spectre%" NEQ "" (
             set "__VCVARS_VC_LIB_ONECORE_OVERRIDE=%VC_LibraryPath_VC_ARM_OneCore_spectre%"
        )

        if "%VC_LibraryPath_ATL_ARM%_spectre" NEQ "" (
             set "__VCVARS_ATL_LIB_OVERRIDE=%VC_LibraryPath_ATL_ARM_spectre%"
        )
    )
)

@REM Set overrides for ARM64 target
if /I "%VSCMD_ARG_TGT_ARCH%" == "ARM64" (
    if "%VC_LibraryPath_VC_ARM64%" NEQ "" (
        set "VCLIB_GENERAL_OVERRIDE=%VC_LibraryPath_VC_ARM64%"
    )

    if /I "%VSCMD_ARG_VCVARS_SPECTRE%" == "spectre" (
        if "%VC_LibraryPath_VC_ARM64_Desktop%" NEQ "" (
            set "__VCVARS_VC_LIB_DESKTOP_OVERRIDE=%VC_LibraryPath_VC_ARM64_Desktop%"
        )

        if "%VC_LibraryPath_VC_ARM64_Store%" NEQ "" (
            set "__VCVARS_VC_LIB_STORE_OVERRIDE=%VC_LibraryPath_VC_ARM64_Store%"
        )

        if "%VC_LibraryPath_VC_ARM64_OneCore%" NEQ "" (
            set "__VCVARS_VC_LIB_ONECORE_OVERRIDE=%VC_LibraryPath_VC_ARM64_OneCore%"
        )

        if "%VC_LibraryPath_ATL_ARM64%" NEQ "" (
            set "__VCVARS_ATL_LIB_OVERRIDE=%VC_LibraryPath_ATL_ARM64%"
        )
    ) else (
        if "%VC_LibraryPath_VC_ARM64_Desktop_spectre%" NEQ "" (
            set "__VCVARS_VC_LIB_DESKTOP_OVERRIDE=%VC_LibraryPath_VC_ARM64_Desktop_spectre%"
        )

        if "%VC_LibraryPath_VC_ARM64_OneCore_spectre%" NEQ "" (
            set "__VCVARS_VC_LIB_ONECORE_OVERRIDE=%VC_LibraryPath_VC_ARM64_OneCore_spectre%"
        )

        if "%VC_LibraryPath_ATL_ARM64_spectre%" NEQ "" (
            set "__VCVARS_ATL_LIB_OVERRIDE=%VC_LibraryPath_ATL_ARM64_spectre%"
        )
    )          
)

@REM -- Setting includes path overrides --
if "%VC_IFCPath%" NEQ "" (
    set "__VCVARS_IFC_PATH_OVERRIDE=%VC_IFCPath%"
)

if "%VC_VC_IncludePath%" NEQ "" (
    set "__VCVARS_VC_INCLUDE_OVERRIDE=%VC_VC_IncludePath%"
)

if "%VC_VS_IncludePath%" NEQ "" (
    set "__VCVARS_VS_INCLUDE_OVERRIDE=%VC_VS_IncludePath%"
)

if "%VC_ATLMFC_IncludePath%" NEQ "" (
    set "__VCVARS_ATLMFC_INCLUDE_OVERRIDE=%VC_ATLMFC_IncludePath%"
)

@REM Translate general VC Lib setting to specific.
if "%VCLIB_GENERAL_OVERRIDE%" NEQ "" (
    if /I "%_VC_Target_Library_Platform%"=="Desktop" (
        if "%__VCVARS_VC_LIB_DESKTOP_OVERRIDE%"=="" (
            if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Using general VC Library path "%VCLIB_GENERAL_OVERRIDE%" as Desktop VC Library path
            set "__VCVARS_VC_LIB_DESKTOP_OVERRIDE=%VCLIB_GENERAL_OVERRIDE%"
        )
    )

    if /I "%_VC_Target_Library_Platform%"=="Store" (
        if "%__VCVARS_VC_LIB_STORE_OVERRIDE%"=="" (
            if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Using general VC Library path "%VCLIB_GENERAL_OVERRIDE%" as Store VC Library path
            set "__VCVARS_VC_LIB_STORE_OVERRIDE=%VCLIB_GENERAL_OVERRIDE%"
        )
    )

    if /I "%_VC_Target_Library_Platform%"=="OneCore" (
        if "%__VCVARS_VC_LIB_ONECORE_OVERRIDE%"=="" (
            if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Using general VC Library path "%VCLIB_GENERAL_OVERRIDE%" as OneCore VC Library path
            set "__VCVARS_VC_LIB_ONECORE_OVERRIDE=%VCLIB_GENERAL_OVERRIDE%"
        )
    )
)

@REM Override for always-added x86 store references
if "%VC_LibraryPath_VC_x86_Store%" NEQ "" (
     set "__VCVARS_X86_STORE_REF_OVERRIDE=%VC_LibraryPath_VC_x86_Store%\references"
)

if "%VSCMD_DEBUG%" GEQ "2" (
    if "%__VCVARS_BIN_OVERRIDE%" NEQ "" @echo [DEBUG:ext\%~nx0] Detected binaries path override: "%__VCVARS_BIN_OVERRIDE%"
    if "%__VCVARS_VC_LIB_DESKTOP_OVERRIDE%" NEQ "" @echo [DEBUG:ext\%~nx0] Detected Desktop VC library path override: "%__VCVARS_VC_LIB_DESKTOP_OVERRIDE%"
    if "%__VCVARS_VC_LIB_STORE_OVERRIDE%" NEQ "" @echo [DEBUG:ext\%~nx0] Detected Store VC library path override: "%__VCVARS_VC_LIB_STORE_OVERRIDE%"
    if "%__VCVARS_VC_LIB_ONECORE_OVERRIDE%" NEQ "" @echo [DEBUG:ext\%~nx0] Detected OneCore VC library path override: "%__VCVARS_VC_LIB_ONECORE_OVERRIDE%"
    if "%__VCVARS_ATL_LIB_OVERRIDE%" NEQ "" @echo [DEBUG:ext\%~nx0] Detected ATL library path override: "%__VCVARS_ATL_LIB_OVERRIDE%"
    if "%__VCVARS_IFC_PATH_OVERRIDE%" NEQ "" @echo [DEBUG:ext\%~nx0] Detected IFC path override: "%__VCVARS_IFC_PATH_OVERRIDE%"
    if "%__VCVARS_VC_INCLUDE_OVERRIDE%" NEQ "" @echo [DEBUG:ext\%~nx0] Detected VC includes path override: "%__VCVARS_VC_INCLUDE_OVERRIDE%"
    if "%__VCVARS_VS_INCLUDE_OVERRIDE%" NEQ "" @echo [DEBUG:ext\%~nx0] Detected VS includes path override: "%__VCVARS_VS_INCLUDE_OVERRIDE%"
    if "%__VCVARS_ATLMFC_INCLUDE_OVERRIDE%" NEQ "" @echo [DEBUG:ext\%~nx0] Detected ATLMFC includes path override: "%__VCVARS_ATLMFC_INCLUDE_OVERRIDE%"
    if "%__VCVARS_X86_STORE_REF_OVERRIDE%" NEQ "" @echo [DEBUG:ext\%~nx0] Detected x86 Store References path override: "%__VCVARS_X86_STORE_REF_OVERRIDE%"
)

set VCLIB_GENERAL_OVERRIDE=

exit /B 0

@REM ------------------------------------------------------------------------
:vcvars_environment

if NOT EXIST "%VSINSTALLDIR%VC\" (
    @REM Once this script has been moved into a VC++-specific component, this
    @REM debug message should be converted to an ERROR.
    if "%VSCMD_DEBUG%" GEQ "1" @echo [DEBUG:ext\%~nx0] Could not find directory "%VSINSTALLDIR%VC\"
    goto :end
)

set "VCINSTALLDIR=%VSINSTALLDIR%VC\"
set "VCIDEInstallDir=%VSINSTALLDIR%Common7\IDE\VC\"

goto :export_env

@REM ------------------------------------------------------------------------
:print_help

@echo     -vcvars_ver=version : Version of VC++ Toolset to select
@echo            ** [Default]   : If -vcvars_ver=version is NOT specified, the toolset specified by
@echo                             [VSInstallDir]\VC\Auxiliary\Build\Microsoft.VCToolsVersion.v143.default.txt will be used.
@echo            ** 14.0        : VS 2015 (v140) VC++ Toolset (installation of the v140 toolset is a prerequisite)
@echo            ** 14.xx       : VS 2017 or VS 2019 VC++ Toolset, if that version is installed on the system under 
@echo                             [VSInstallDir]\VC\MSVC\Tools\[version].  Where '14.xx' specifies a partial 
@echo                             [version]. The latest [version] directory that matches the specified value will 
@echo                             be used.
@echo            ** 14.xx.yyyyy : VS 2017 or VS 2019 VC++ Toolset, if that version is installed on the system under 
@echo                             [VSInstallDir]\VC\MSVC\Tools\[version]. Where '14.xx.yyyyy' specifies an 
@echo                             exact [version] directory to be used.
@echo            ** 14.xx.VV.vv : VS 2019 C++ side-by-side toolset package identity alias, if the SxS toolset has been installed on the system.
@echo                             Where '14.xx.VV.vv' corresponds to a SxS toolset
@echo                                 VV = VS Update Major Version (e.g. "16" for VS 2019 v16.9)
@echo                                 vv = VS Update Minor version (e.g. "9" for VS 2019 v16.9)
@echo                             Please see [VSInstallDir]\VC\Auxiliary\Build\[version]\Microsoft.VCToolsVersion.[version].txt for mapping of 
@echo                             SxS toolset to [VSInstallDir]\VC\MSVC\Tools\ directory. 
@echo     -vcvars_spectre_libs=mode : version of libraries to use.
@echo            ** [Default]   : If -vcvars_spectre_libs=libraries is NOT specified, the project will use the normal
@echo                             libraries.
@echo            ** spectre     : The project will use libraries compiled with spectre mitigations.

exit /B 0
@REM ------------------------------------------------------------------------
:export_parse_variables

set "VSCMD_ARG_VCVARS_VER=%__VSCMD_ARG_VCVARS_VER%"
set "VSCMD_ARG_VCVARS_SPECTRE=%__VSCMD_ARG_VCVARS_SPECTRE%"

goto :end
@REM ------------------------------------------------------------------------
:parse_arg_inner

@REM -- /vcvars_ver --
if /I "%1"=="-vcvars_ver" (
    set "__VSCMD_ARG_VCVARS_VER=%2"
    set "__local_arg_found=1"
)

if /I "%1"=="/vcvars_ver" (
    set "__VSCMD_ARG_VCVARS_VER=%2"
    set "__local_arg_found=1"
)

@REM -- /vcvars_spectre_libs --
if /I "%1"=="-vcvars_spectre_libs" (
    set "__VSCMD_ARG_VCVARS_SPECTRE=%2"
    set "__local_arg_found=1"
)

if /I "%1"=="/vcvars_spectre_libs" (
    set "__VSCMD_ARG_VCVARS_SPECTRE=%2"
    set "__local_arg_found=1"
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

set VSCMD_ARG_VCVARS_VER=
set VSCMD_ARG_VCVARS_SPECTRE=
set VCINSTALLDIR=
set VCToolsInstallDir=
set VCToolsRedistDir=
set VCIDEInstallDir=
set Platform=
set CommandPromptType=
set PreferredToolArchitecture=
set VCTargetsUnderVCInstall=
set ExtensionSdkDir=
set VCToolsVersion=%__VSCMD_PREINIT_VCToolsVersion%
set __VSCMD_PREINIT_VCToolsVersion=
set IFCPATH=

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
call :add_to_path_optional "%VSINSTALLDIR%Common7\IDE\VC\VCPackages" "%__VCVARS_NO_OVERRIDE%"


@REM Add MSVC
set "__VCVARS_DEFAULT_CONFIG_FILE=%VCINSTALLDIR%Auxiliary\Build\Microsoft.VCToolsVersion.default.txt"

@REM We will "fallback" to Microsoft.VCToolsVersion.default.txt (latest) if Microsoft.VCToolsVersion.v143.default.txt does not exist.
if EXIST "%VCINSTALLDIR%Auxiliary\Build\Microsoft.VCToolsVersion.v143.default.txt" (
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Microsoft.VCToolsVersion.v143.default.txt was found.
    set "__VCVARS_DEFAULT_CONFIG_FILE=%VCINSTALLDIR%Auxiliary\Build\Microsoft.VCToolsVersion.v143.default.txt"

) else (
    if "%VSCMD_DEBUG%" GEQ "1" @echo [DEBUG:ext\%~nx0] Microsoft.VCToolsVersion.v143.default.txt was not found. Defaulting to 'Microsoft.VCToolsVersion.default.txt'.
)

@REM if __VCVARS_VERSION is defined, user override was detected. Use this instead of default.
if "%__VCVARS_VERSION%" NEQ "" (
    set __VCVARS_TOOLS_VERSION=%__VCVARS_VERSION%
    goto :export_env_vctoolsinstalldir
)

if not exist "%__VCVARS_DEFAULT_CONFIG_FILE%" (
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Could not find configuration file "%__VCVARS_DEFAULT_CONFIG_FILE%".
    goto :end
)

@REM Use 'type' with double quotes to escape parentheses.
for /F %%A in ('type "%__VCVARS_DEFAULT_CONFIG_FILE%"') do (
    set "__VCVARS_TOOLS_VERSION=%%A"
)

if "%__VCVARS_TOOLS_VERSION%"=="" (
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Could not determine VC++ tools version.
    goto :end
)

:export_env_vctoolsinstalldir
if exist "%VCINSTALLDIR%Tools\MSVC\%__VCVARS_TOOLS_VERSION%\" (
    set "VCToolsInstallDir=%VCINSTALLDIR%Tools\MSVC\%__VCVARS_TOOLS_VERSION%\"
    set "VCToolsVersion=%__VCVARS_TOOLS_VERSION%"
) else (
    set VCToolsInstallDir=
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Could not find VC++ tools version "%__VCVARS_TOOLS_VERSION%" under "%VCINSTALLDIR%Tools\MSVC\".
    goto :end
)

set "__VCVARS_DEFAULT_REDIST_FILE=%VCINSTALLDIR%Auxiliary\Build\Microsoft.VCRedistVersion.default.txt"
if not exist "%__VCVARS_DEFAULT_REDIST_FILE%" (
    if "%VSCMD_DEBUG%" GEQ "1" @echo [DEBUG:ext\%~nx0] Could not find configuration file "%__VCVARS_DEFAULT_REDIST_FILE%", skipping.
    goto :skip_default_redist_file
)

@REM Use 'type' with double quotes to escape parentheses.
for /F %%A in ('type "%__VCVARS_DEFAULT_REDIST_FILE%"') do (
    set "__VCVARS_REDIST_VERSION=%%A"
)

if "%VSCMD_DEBUG%" GEQ "2" @echo __VCVARS_REDIST_VERSION=%__VCVARS_REDIST_VERSION%

if exist "%VCINSTALLDIR%Redist\MSVC\%__VCVARS_REDIST_VERSION%\" (
    set "VCToolsRedistDir=%VCINSTALLDIR%Redist\MSVC\%__VCVARS_REDIST_VERSION%\"
) else (
    set VCToolsRedistDir=
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Could not find VC++ tools version "%__VCVARS_REDIST_VERSION%" under "%VCINSTALLDIR%Redist\MSVC\".
)

@REM if the Microsoft.VCRedistVersion.default.txt
:skip_default_redist_file

@REM set the IFCPATH directory for modules
call :set_ifcpath_optional "%VCToolsInstallDir%ifc%__VCVARS_TARGET_DIR%" "%__VCVARS_IFC_PATH_OVERRIDE%"

@REM for cross compiler scenarios, add the native host compiler toolset directory to PATH
@REM before adding the cross compiler directory.
if /I "%CommandPromptType%"=="Cross" (
    call :add_to_path_optional "%VCToolsInstallDir%bin%__VCVARS_HOST_DIR%%__VCVARS_HOST_NATIVEDIR%" "%__VCVARS_NATIVE_BIN_OVERRIDE%"
)
call :add_to_path_optional "%VCToolsInstallDir%bin%__VCVARS_BIN_DIR%" "%__VCVARS_BIN_OVERRIDE%"

call :add_to_include_optional "%VSINSTALLDIR%VC\Auxiliary\VS\include" "%__VCVARS_VS_INCLUDE_OVERRIDE%"
call :add_to_include_optional "%VCToolsInstallDir%ATLMFC\include" "%__VCVARS_ATLMFC_INCLUDE_OVERRIDE%"
call :add_to_include_optional "%VCToolsInstallDir%include" "%__VCVARS_VC_INCLUDE_OVERRIDE%"

call :add_to_libpath_optional "%VCToolsInstallDir%lib\x86\store\references" "%__VCVARS_X86_STORE_REF_OVERRIDE%"

@REM Set LIB based upon target platform
if /I "%VSCMD_ARG_APP_PLAT%"=="Desktop" (
    call :check_spectre_install "%VCToolsInstallDir%lib" "%VCToolsInstallDir%lib%__VCVARS_SPECTRE_DIR%" "c++"
    call :check_spectre_install "%VCToolsInstallDir%ATLMFC\lib" "%VCToolsInstallDir%ATLMFC\lib%__VCVARS_SPECTRE_DIR%" "ATLMFC"
    call :add_to_lib_optional "%VCToolsInstallDir%lib%__VCVARS_SPECTRE_DIR%%__VCVARS_LIB_DIR%" "%__VCVARS_VC_LIB_DESKTOP_OVERRIDE%"
    call :add_to_lib_optional "%VCToolsInstallDir%ATLMFC\lib%__VCVARS_SPECTRE_DIR%%__VCVARS_LIB_DIR%" "%__VCVARS_ATL_LIB_OVERRIDE%"
    call :add_to_libpath_optional "%VCToolsInstallDir%lib%__VCVARS_SPECTRE_DIR%%__VCVARS_LIB_DIR%" "%__VCVARS_VC_LIB_DESKTOP_OVERRIDE%"
    call :add_to_libpath_optional "%VCToolsInstallDir%ATLMFC\lib%__VCVARS_SPECTRE_DIR%%__VCVARS_LIB_DIR%" "%__VCVARS_ATL_LIB_OVERRIDE%"
)

@REM ... set _checkWin81 so it will not match if the Windows 8.1 SDK has been selected/specified.
set "__checkWin81=%WindowsSdkDir:8.1=FOUND%"
if "%__checkWin81%" NEQ "%WindowsSdkDir%" goto :check_win81_app_platform

@REM Windows 10 SDK only past this point
if /I "%VSCMD_ARG_APP_PLAT%"=="UWP" (
    call :add_to_lib_optional "%VCToolsInstallDir%lib%__VCVARS_LIB_DIR%\store\" "%__VCVARS_VC_LIB_STORE_OVERRIDE%"
    call :add_to_libpath_optional "%ExtensionSDKDir%\Microsoft.VCLibs\14.0\References\CommonConfiguration\neutral" "%__VCVARS_NO_OVERRIDE%"
)

if /I "%VSCMD_ARG_APP_PLAT%"=="OneCore" (
    call :check_spectre_install "%VCToolsInstallDir%lib\onecore" "%VCToolsInstallDir%lib\onecore%__VCVARS_SPECTRE_DIR%" "onecore"
    call :add_to_lib_optional "%VCToolsInstallDir%lib\onecore%__VCVARS_SPECTRE_DIR%%__VCVARS_LIB_DIR%" "%__VCVARS_VC_LIB_ONECORE_OVERRIDE%"
    call :add_to_libpath_optional "%VCToolsInstallDir%lib\onecore%__VCVARS_SPECTRE_DIR%%__VCVARS_LIB_DIR%" "%__VCVARS_VC_LIB_ONECORE_OVERRIDE%"
)

goto :end

@REM ------------------------------------------------------------------------
@REM add_to_path_optional <path> <override>
:add_to_path_optional
if "%~2"=="" (
    set "__VCVARS_ADD_TO_PATH=%~1"
) else (
    set "__VCVARS_ADD_TO_PATH=%~2"
)

if exist "%__VCVARS_ADD_TO_PATH%" (
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Adding "%__VCVARS_ADD_TO_PATH%"
    set "PATH=%__VCVARS_ADD_TO_PATH%;%PATH%"
    exit /B 0
) else (
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Could not add directory to PATH: "%__VCVARS_ADD_TO_PATH%"
    exit /B 1
)

@REM ------------------------------------------------------------------------
@REM add_to_lib_optional <path> <override>
:add_to_lib_optional
if "%~2"=="" (
    set "__VCVARS_ADD_TO_LIB=%~1"
) else (
    set "__VCVARS_ADD_TO_LIB=%~2"
)

if exist "%__VCVARS_ADD_TO_LIB%" (
    set "LIB=%__VCVARS_ADD_TO_LIB%;%LIB%"
    exit /B 0
) else (
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Could not add directory to LIB: "%__VCVARS_ADD_TO_LIB%"
    exit /B 1
)

@REM ------------------------------------------------------------------------
@REM add_to_libpath_optional <path> <override>
:add_to_libpath_optional
if "%~2"=="" (
    set "__VCVARS_ADD_TO_LIBPATH=%~1"
) else (
    set "__VCVARS_ADD_TO_LIBPATH=%~2"
)

if exist "%__VCVARS_ADD_TO_LIBPATH%" (
    set "LIBPATH=%__VCVARS_ADD_TO_LIBPATH%;%LIBPATH%"
    exit /B 0
) else (
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Could not add directory to LIBPATH: "%__VCVARS_ADD_TO_LIBPATH%"
    exit /B 1
)

@REM ------------------------------------------------------------------------
@REM add_to_include_optional <path> <override>
:add_to_include_optional
if "%~2"=="" (
    set "__VCVARS_ADD_TO_INCLUDE=%~1"
) else (
    set "__VCVARS_ADD_TO_INCLUDE=%~2"
)

if exist "%__VCVARS_ADD_TO_INCLUDE%" (
@REM Use vcvars-specific INCLUDE variable to ensure include ordering is coordinated with msbuild.
    set "__VSCMD_VCVARS_INCLUDE=%__VCVARS_ADD_TO_INCLUDE%;%__VSCMD_VCVARS_INCLUDE%"
    exit /B 0
) else (
    if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Could not add directory to INCLUDE: "%__VCVARS_ADD_TO_INCLUDE%"
    exit /B 1
)

@REM ------------------------------------------------------------------------
:check_spectre_install
if "%__VCVARS_SPECTRE_DIR%" NEQ "" (
    if exist "%~1" (
        if not exist "%~2" (
            @echo [ERROR:%~nx0] Spectre is not installed for '%~3' verify compatibility for '%__VCVARS_VERSION%' with spectre
            exit /B 1
        )
    )
)
exit /B 0

@REM ------------------------------------------------------------------------
@REM set_ifcpath_optional <path> <override>
:set_ifcpath_optional

@REM IFCPATH is expected to be a single path, not a path list. Modules created
@REM by the user (or from another library) would be explicitly referenced via
@REM compiler command line argument.

if "%~2"=="" (
    set "__VCVARS_SET_IFCPATH=%~1"
) else (
    set "__VCVARS_SET_IFCPATH=%~2"
)

if "%IFCPATH%"=="" (
    if exist "%__VCVARS_SET_IFCPATH%" (
        set "IFCPATH=%__VCVARS_SET_IFCPATH%"
        exit /B 0
    ) else (
        if "%VSCMD_DEBUG%" GEQ "2" @echo [DEBUG:ext\%~nx0] Could not add directory to IFCPATH: "%__VCVARS_SET_IFCPATH%"
        exit /B 1
    )
) else (
    if "%VSCMD_DEBUG%" GEQ "1" @echo [DEBUG:ext\%~nx0] IFCPATH was not modified. IFCPATH already set: "%IFCPATH%".
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
:vcvars140_version
@REM Initialization script for the 14.0 / v140 toolset. This script does not
@REM sit in vsdevcmd\ext directly, so it will not be automatically invoked
@REM as part of normal "EXT" processing.
call "%~dp0\vcvars\vcvars140.bat"
if "%ERRORLEVEL%" NEQ "0" set __VCVARS_SCRIPT_ERROR=1
goto :end

@REM ------------------------------------------------------------------------
:end

set __VSCMD_ARG_VCVARS_VER=
set __VSCMD_ARG_VCVARS_SPECTRE=
set __VCVARS_HOST_DIR=
set __VCVARS_SPECTRE_DIR=
set __VCVARS_HOST_NATIVEDIR=
set __VCVARS_TARGET_DIR=
set __VCVARS_BIN_DIR=
set __VCVARS_LIB_DIR=
set __VCVARS_TOOLS_VERSION=
set __VCVARS_REDIST_VERSION=
set __VCVARS_DEFAULT_CONFIG_FILE=
set __VCVARS_DEFAULT_REDIST_FILE=
set __VCVARS_VERSION=
set __VCVARS_NATIVE_BIN_OVERRIDE=
set __VCVARS_BIN_OVERRIDE=
set __VCVARS_VC_LIB_DESKTOP_OVERRIDE=
set __VCVARS_VC_LIB_STORE_OVERRIDE=
set __VCVARS_VC_LIB_ONECORE_OVERRIDE=
set __VCVARS_ATL_LIB_OVERRIDE=
set __VCVARS_IFC_PATH_OVERRIDE=
set __VCVARS_VC_INCLUDE_OVERRIDE=
set __VCVARS_VS_INCLUDE_OVERRIDE=
set __VCVARS_ATLMFC_INCLUDE_OVERRIDE=
set __VCVARS_ADD_TO_PATH=
set __VCVARS_ADD_TO_LIB=
set __VCVARS_ADD_TO_LIBPATH=
set __VCVARS_ADD_TO_INCLUDE=
set __VCVARS_SET_IFCPATH=
set __VCVARS_SXS_FILE=
set __VCVARS_SXS_VERSION=
set __VCVARS_VER_TMP=

set __checkWin81=

if "%__VCVARS_SCRIPT_ERROR%" NEQ "" (
   set __VCVARS_SCRIPT_ERROR=
   exit /B 1
)
exit /B 0
