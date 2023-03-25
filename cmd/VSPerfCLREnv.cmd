@echo off

if /i "%2" neq "" goto oneargumentonly

@REM
@REM This is the Tracing Profiler GUID
@REM
set TRACE_GUID={33708259-ba1b-4add-9de4-d4f280ea1223}

if /i "%1"=="/traceon"              goto trace_on

if /i "%1"=="/interactionon"        goto interaction_on

if /i "%1"=="/off"                  goto profile_off

if /i "%1"=="/globaltraceon"        goto profile_global
if /i "%1"=="/globalinteractionon"  goto profile_global

if /i "%1"=="/globaloff"            goto profile_global

if /i "%1"=="/?" goto usage
goto usage

:trace_on
@echo Enabling VSPerf Trace Profiling of managed applications (excluding allocation profiling).
set COR_ENABLE_PROFILING=1
set COR_PROFILER=%TRACE_GUID%
set COR_LINE_PROFILING=0
set COR_INTERACTION_PROFILING=0
set COR_GC_PROFILING=0
set CORECLR_ENABLE_PROFILING=1
set CORECLR_PROFILER=%TRACE_GUID%
title VSPerf Trace Profiling 'ON'
goto show_settings

:interaction_on
@echo Enables collection of interaction profiling data for managed applications
set COR_INTERACTION_PROFILING=1
goto show_settings

:profile_off
@echo Disabling VSPerf Trace Profiling.
set COR_ENABLE_PROFILING=
set COR_PROFILER=
set COR_LINE_PROFILING=
set COR_INTERACTION_PROFILING=
set COR_GC_PROFILING=
set CORECLR_ENABLE_PROFILING=
set CORECLR_PROFILER=
title VSPerf Tracing 'OFF'
goto show_settings

:profile_global
@rem
@rem make output file
@rem
IF NOT DEFINED TEMP SET TEMP=.\
SET TEMPF="%TEMP%\VSPERFENV.js"
del /Q %TEMPF% >nul 2>&1

@rem Wrap up our registry calls in a try catch block
echo try { > %TEMPF%

if /i "%1"=="/globaltraceon"        goto profile_global_trace_on
if /i "%1"=="/globaloff"            goto profile_global_off
if /i "%1"=="/globalinteractionon"  goto profile_global_interaction_on

:profile_global_interaction_on
@rem
@rem Add to HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
@rem
echo var WshShell = WScript.CreateObject("WScript.Shell"); >> %TEMPF%
echo WshShell.RegWrite ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\COR_INTERACTION_PROFILING", "1", "REG_SZ"); >> %TEMPF%
goto global_finish_no_reboot

:profile_global_trace_on
@echo Enabling VSPerf Global Profiling. Allows trace profiling of managed services without allocation profiling.
@rem
@rem Add to HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
@rem
echo var WshShell = WScript.CreateObject("WScript.Shell"); >> %TEMPF%
echo WshShell.RegWrite ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\COR_ENABLE_PROFILING", "1", "REG_SZ"); >> %TEMPF%
echo WshShell.RegWrite ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\COR_PROFILER", "%TRACE_GUID%", "REG_SZ"); >> %TEMPF%
echo WshShell.RegWrite ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\COR_LINE_PROFILING", "0", "REG_SZ"); >> %TEMPF%
echo WshShell.RegWrite ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\COR_INTERACTION_PROFILING", "0", "REG_SZ"); >> %TEMPF%
echo WshShell.RegWrite ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\COR_GC_PROFILING", "0", "REG_SZ"); >> %TEMPF%
echo WshShell.RegWrite ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\CORECLR_ENABLE_PROFILING", "1", "REG_SZ"); >> %TEMPF%
echo WshShell.RegWrite ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\CORECLR_PROFILER", "1", "REG_SZ"); >> %TEMPF%
title VSPerf Global Profiling 'ON'
goto global_finish

:profile_global_off
@echo Disabling VSPerf Global Profiling.
@rem
@rem Remove key from HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
@rem
echo  HKLM = 0x80000002; >> %TEMPF%
echo  sRegPath = "SYSTEM\\CurrentControlSet\\Services\\"; >> %TEMPF%
echo  WshShell = WScript.CreateObject("WScript.Shell");  >> %TEMPF%
echo  WshShell.RegDelete ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\COR_ENABLE_PROFILING"); >> %TEMPF%
echo  WshShell.RegDelete ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\COR_PROFILER"); >> %TEMPF%
echo  WshShell.RegDelete ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\COR_LINE_PROFILING"); >> %TEMPF%
echo  WshShell.RegDelete ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\COR_INTERACTION_PROFILING"); >> %TEMPF%
echo  WshShell.RegDelete ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\COR_GC_PROFILING"); >> %TEMPF%
echo  WshShell.RegDelete ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\CORECLR_ENABLE_PROFILING"); >> %TEMPF%
echo  WshShell.RegDelete ("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\CORECLR_PROFILER"); >> %TEMPF%
echo    WScript.Echo( "You need to restart the service to detect the new settings. This may require a reboot of your machine." ); >> %TEMPF%
echo } >> %TEMPF%
echo catch (err) >> %TEMPF%
echo { >> %TEMPF%
echo      WScript.Echo( "Could not remove registry keys. Either they do not exist, or you are not running as an administrator." ); >> %TEMPF%
echo } >> %TEMPF%

goto global_runscript

:global_finish

@rem Add in the end of the try block, and the catch block
echo WScript.Echo( "You need to restart the service to detect the new settings. This may require a reboot of your machine." ); >> %TEMPF%

:global_finish_no_reboot

echo } >> %TEMPF%
echo catch (e) { >> %TEMPF%
echo WScript.Echo( ); >> %TEMPF%
echo WScript.Echo( "Error in writing to registry. You must be an administrator to change any global sampling settings." ); >> %TEMPF%
echo } >> %TEMPF%
goto global_runscript

:global_runscript

cscript //Nologo %TEMPF%
@rem del /Q %TEMPF% >nul 2>&1
set TEMPF=
goto end

:show_settings
@echo.
@echo Current Profiling Environment variables are:
set COR_ENABLE_PROFILING
set COR_PROFILER
set COR_LINE_PROFILING
set COR_INTERACTION_PROFILING
set COR_GC_PROFILING
set CORECLR_ENABLE_PROFILING
set CORECLR_PROFILER
goto end

:oneargumentonly
@echo.
@echo Microsoft (R) Visual Studio Performance Tools .NET Profiling Utility for managed code
@echo Copyright (C) Microsoft Corporation. All rights reserved.
@echo.
@echo To apply multiple arguments - run the script multiple times with one argument each time.
@echo VSPerfCLREnv [/?] for more details.
goto end

:usage
@echo.
@echo Microsoft (R) Visual Studio Performance Tools .NET Profiling Utility for managed code
@echo Copyright (C) Microsoft Corporation. All rights reserved.
@echo.
@echo Usage: VSPerfCLREnv [/?]
@echo                     [/traceon^|/interactionon^|
@echo                      /globaltraceon^|/globalinteractionon^|
@echo                      /off^|/globaloff^]
@echo.
@echo This script is for setting the profiling environment for managed code.
@echo.
@echo Options:
@echo.
@echo./?                      Displays this help
@echo.
@echo /traceon                Enables trace profiling of managed applications (excluding allocation profiling)
@echo.
@echo /interactionon          Enables collection of interaction profiling data for managed applications
@echo.
@echo.
@echo /globaltraceon          Enables trace profiling of managed services (excluding allocation profiling)
@echo.
@echo /globalinteractionon    Enables global collection of interaction profiling data for managed applications
@echo.
@echo.
@echo /off                    Disables trace reporting of managed applications
@echo.
@echo /globaloff              Disables trace profiling of managed services
@echo.

:end
set TRACE_GUID=
