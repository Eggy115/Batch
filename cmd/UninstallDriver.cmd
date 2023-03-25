@echo off
CLS
setlocal enabledelayedexpansion

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    wscript "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

echo **************************************************************
echo ***  Batch Uninstall Realtek Wireless LAN Driver               
echo ***                                                            
echo ***  Please wait a moment	                  
echo=

if %PROCESSOR_ARCHITECTURE%==AMD64 (
    set WiFiDIR="C:\Program Files (x86)\Realtek\PCIE Wireless LAN"
    set DriverSrcPath="%~dp0RTWLANE_Driver\Win10X64"
    set DPInstPath="%~dp0RTWLANE_Driver\DPInst\X64"
)
if %PROCESSOR_ARCHITECTURE%==x86 (
    set WiFiDIR="C:\Program Files\Realtek\PCIE Wireless LAN"
    set DriverSrcPath="%~dp0RTWLANE_Driver\Win10X86"
    set DPInstPath="%~dp0RTWLANE_Driver\DPInst\X86"
)

set sourcePath="%TEMP%\Realtek\RTWLANE_Install"
if NOT exist %sourcePath% (mkdir %sourcePath%)
set logPath="%ProgramData%\HP\Logs\Realtek"
if NOT exist %logPath% (mkdir %logPath%)

set var=%sourcePath:~1,-1%

xcopy /y %DriverSrcPath%\* "%var%\" /s /e > nul
xcopy /y %DPInstPath%\* "%var%\" /s /e > nul

set logfile=%logPath%\WiFiUninst.log
echo ----- %date% %time% ----- Uninstallation BEGIN > %logfile%

"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_8852*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_A85A*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_A852*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_D723*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_C822*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_C821*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_C82B*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_8813*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_B822*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_B814*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_B821*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_8812*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_8821*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_818B*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_818C*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_8753*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_B723*" >> %logfile%
"%var%\devcon.exe" remove "@PCI\VEN_10EC&DEV_8179*" >> %logfile%

"%var%\dpinst.exe" /Q /D /U "%var%\netrtwlane6.inf" >> %logfile%
"%var%\dpinst.exe" /Q /D /U "%var%\netrtwlane.inf" >> %logfile%
"%var%\dpinst.exe" /Q /D /U "%var%\netrtwlane02.inf" >> %logfile%

REM ---> Delete all netrtwlane6.inf
chcp 65001
set GetVersion=Disable
set deleteDriver=Disable
set RTPublishedName=NULL
FOR /f "tokens=2,3,4 delims=: " %%I IN ('pnputil /enum-drivers') do (
	set PublishedName=!OriginalName!
	set OriginalName=%%J
	if "!OriginalName!"=="netrtwlane6.inf" (
		call set RTPublishedName=!PublishedName!
		echo ---^> >> %logfile%
		echo !PublishedName! >> %logfile%
		call set GetVersion=Enable
	)
	if "%%I"=="Version" (
		if "!GetVersion!"=="Enable" (
			echo Driver Version: %%J %%K >> %logfile%
			call set GetVersion=Disable
			call set deleteDriver=Enable
		)
	)
	if "!deleteDriver!"=="Enable" (
		pnputil /delete-driver !RTPublishedName! >> %logfile%
		call set deleteDriver=Disable
		echo ^<--- >> %logfile%
	)
)
REM ---> Delete all netrtwlane.inf Finish

REM ---> Delete all netrtwlane.inf
chcp 65001
set GetVersion=Disable
set deleteDriver=Disable
set RTPublishedName=NULL
FOR /f "tokens=2,3,4 delims=: " %%I IN ('pnputil /enum-drivers') do (
	set PublishedName=!OriginalName!
	set OriginalName=%%J
	if "!OriginalName!"=="netrtwlane.inf" (
		call set RTPublishedName=!PublishedName!
		echo ---^> >> %logfile%
		echo !PublishedName! >> %logfile%
		call set GetVersion=Enable
	)
	if "%%I"=="Version" (
		if "!GetVersion!"=="Enable" (
			echo Driver Version: %%J %%K >> %logfile%
			call set GetVersion=Disable
			call set deleteDriver=Enable
		)
	)
	if "!deleteDriver!"=="Enable" (
		pnputil /delete-driver !RTPublishedName! >> %logfile%
		call set deleteDriver=Disable
		echo ^<--- >> %logfile%
	)
)
REM ---> Delete all netrtwlane.inf Finish

REM ---> Delete all netrtwlane02.inf
chcp 65001
set GetVersion=Disable
set deleteDriver=Disable
set RTPublishedName=NULL
FOR /f "tokens=2,3,4 delims=: " %%I IN ('pnputil /enum-drivers') do (
	set PublishedName=!OriginalName!
	set OriginalName=%%J
	if "!OriginalName!"=="netrtwlane02.inf" (
		call set RTPublishedName=!PublishedName!
		echo ---^> >> %logfile%
		echo !PublishedName! >> %logfile%
		call set GetVersion=Enable
	)
	if "%%I"=="Version" (
		if "!GetVersion!"=="Enable" (
			echo Driver Version: %%J %%K >> %logfile%
			call set GetVersion=Disable
			call set deleteDriver=Enable
		)
	)
	if "!deleteDriver!"=="Enable" (
		pnputil /delete-driver !RTPublishedName! >> %logfile%
		call set deleteDriver=Disable
		echo ^<--- >> %logfile%
	)
)
REM ---> Delete all netrtwlane02.inf Finish

"%var%\devcon.exe" rescan >> %logfile%

set TARGET_SERVICE=rtwlane6
set SERVICE_STATE=

for /F "skip=3 tokens=3" %%A in ('""%windir%\system32\sc.exe" query "%TARGET_SERVICE%" 2>nul"') do (
if not defined SERVICE_STATE set SERVICE_STATE = %%A
)
echo Servcie State is %SERVICE_STATE% >> %logfile%

if not defined SERVICE_STATE (
  echo INFORMATION: could not obtain service state! >> %logfile%
) else (
if "%SERVICE_STATE%"=="1" (
echo WARNING: service is Stopped >> %logfile%
"%windir%\system32\sc.exe" delete "%TARGET_SERVICE%" >> %logfile%
"%windir%\system32\sc.exe" queryex "%TARGET_SERVICE%" >> %logfile%
)
)

set TARGET_SERVICE=rtwlane
set SERVICE_STATE=

for /F "skip=3 tokens=3" %%A in ('""%windir%\system32\sc.exe" query "%TARGET_SERVICE%" 2>nul"') do (
if not defined SERVICE_STATE set SERVICE_STATE = %%A
)
echo Servcie State is %SERVICE_STATE% >> %logfile%

if not defined SERVICE_STATE (
  echo INFORMATION: could not obtain service state! >> %logfile%
) else (
if "%SERVICE_STATE%"=="1" (
echo WARNING: service is Stopped >> %logfile%
"%windir%\system32\sc.exe" delete "%TARGET_SERVICE%" >> %logfile%
"%windir%\system32\sc.exe" queryex "%TARGET_SERVICE%" >> %logfile%
)
)

set TARGET_SERVICE=rtwlane02
set SERVICE_STATE=

for /F "skip=3 tokens=3" %%A in ('""%windir%\system32\sc.exe" query "%TARGET_SERVICE%" 2>nul"') do (
if not defined SERVICE_STATE set SERVICE_STATE = %%A
)
echo Servcie State is %SERVICE_STATE% >> %logfile%

if not defined SERVICE_STATE (
  echo INFORMATION: could not obtain service state! >> %logfile%
) else (
if "%SERVICE_STATE%"=="1" (
echo WARNING: service is Stopped >> %logfile%
"%windir%\system32\sc.exe" delete "%TARGET_SERVICE%" >> %logfile%
"%windir%\system32\sc.exe" queryex "%TARGET_SERVICE%" >> %logfile%
)
)

echo ----- %date% %time% ----- Uninstallation END >> %logfile%
type %logfile%

echo=
echo **************************************************************
echo ***  Driver Uninstall Finished              
echo=

rd /q /s %WiFiDIR% >> %logfile%

if exist %sourcePath% (rd /s/q %sourcePath%)