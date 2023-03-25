echo off
REM
REM Copyright (C) Microsoft Corporation.  All rights reserved.
REM
REM Module Name :   Master script for servicing UWF enabled device
REM
REM Abstract    :   
REM This script is responsible for initiating the 
REM servicing of the device with UWF installed.The Script will 
REM call UWF manager application to update the system with the 
REM latest available updates.
REM The script will detect whether the update operation 
REM ended successfully or requires a reboot.
REM
REM The script will change the "SERVICING" state of the device
REM only when the update operation results in a "SUCCESS".
REM A state change of the device requires a reboot.
REM
REM If the update operation requires a "REBOOT" the script will
REM reboot device without changing the "SERVICING" state. The 
REM Will then run again on the following reboot untill it
REM the update operation either return a "SUCCESS" or a "ERROR"
REM
REM After servicing completes, the system's idle tasks will be 
REM triggered to run maintenance. The script will wait until this
REM is complete.
REM
REM Any third party script that needs to run before the state
REM change should run in the UPDATE_SUCCESS block
REM
REM Environment :
REM It is expected that UWF is turned "OFF", "SERVICING" mode 
REM enabled and all other preconditions
REM for servicing are in place. 
REM
REM
REM 


echo UpdateAgent starting.
uwfmgr servicing update-windows
if ERRORLEVEL 3010 goto UPDATE_REBOOT
if ERRORLEVEL 0 goto UPDATE_SUCCESS
echo UpdateAgent returned error =%ERRORLEVEL%
 
:UPDATE_ERROR
uwfmgr servicing disable
echo Restarting system
goto UPDATE_EXIT

:UPDATE_REBOOT
echo UpdateAgent requires a reboot.
echo UpdateAgent restarting system
goto UPDATE_EXIT

:UPDATE_SUCCESS
echo UpdateAgent returned success.

REM
REM Trigger idle maintenance tasks, and wait for completion.
REM Note that ProcessIdleTasksW will do nothing if automatic
REM maintenance is disabled.
REM

echo UpdateAgent executing maintenance tasks.
start /wait rundll32.exe advapi32.dll,ProcessIdleTasksW
echo UpdateAgent maintenance tasks completed.

REM
REM echo UpdateAgent executing OEM script
REM OEM can call their custom scripts
REM at this point thru a "call".
REM
REM The OEM script should hand control
REM back to this script once its done.
REM
REM Any error recovery for OEM script
REM should be handled outside of this script
REM post a reboot.
REM
REM *******************************************************
REM OEM scripts go below this line.
REM 



REM
REM OEM scripts go above this line.
REM *******************************************************
REM

uwfmgr servicing disable
echo Restarting system
goto UPDATE_EXIT

:UPDATE_EXIT
echo UpdateAgent exiting.
shutdown -r -t 5
EXIT /B