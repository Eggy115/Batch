@echo off

rem *************** start of 'main'

set DEBUG=0
if "%DEBUG%"=="1" (set TRACE=echo) else (set TRACE=rem)

rem Note that right now there is a bug in tracerpt.exe cause of which you might want to use tracefmt.exe instead.
rem set the value 1 if you want to use tracefmt.exe instead
set USE_TRACE_FMT=1
%TRACE% The value of variable USE_TRACE_FMT is %USE_TRACE_FMT%

rem define variables for each of the switches we support
set SWHELP=h
set SWMODE=mode
set SWTRACELOG=tracelog
set SWMOF=mof
set SWOUTPUT=o
set VALID=0

rem define variables for parameters to be passed to tracerpt
set TRACEDIR=%WINDIR%\system32\msdtc\trace
set TRACEFILE1=%TRACEDIR%\dtctrace.log
set TRACEFILE2=%TRACEDIR%\tracetx.log
set MOFFILE=%TRACEDIR%\msdtctr.mof
set ERRORFILE=%TRACEDIR%\errortrace.txt
set OUTPUTFILE=%TRACEDIR%\trace

rem Parse command line and setup variables
set CMDLINE=%*
%TRACE% About to call PARSECMDLINE with the argument %CMDLINE%
call :PARSECMDLINE 0

rem Validate the command line
%TRACE% About to call the procedure VALIDATE
call :VALIDATE

rem if Vaidation fails, we give up
if "%VALID%"=="0" (
	%TRACE% Parameter validation failed, exiting ...
	goto :EOF
)

rem depending on the value of the mode, set the tracelogfile
call :MYFINDSWITCH %SWMODE%
if not "%RET%"=="0" (
	if "%RETV%"=="1" set TRACEFILE=%TRACEFILE1%
	if "%RETV%"=="2" set TRACEFILE=%TRACEFILE2%
)

rem if the tracelog switch was used, set the tracelogfile
call :MYFINDSWITCH %SWTRACELOG%
if not "%RET%"=="0" (
	set TRACEFILE=%RETV%
)

rem if the mof switch was used, set the moffile
call :MYFINDSWITCH %SWMOF%
if not "%RET%"=="0" (
	set MOFFILE=%RETV%
)

rem if the output switch was used, set the output file
call :MYFINDSWITCH %SWOUTPUT%
if not "%RET%"=="0" (
	set OUTPUTFILE=%RETV%
)

%TRACE% TRACEFILE=%TRACEFILE%
%TRACE% MOFFILE=%MOFFILE%
%TRACE% OUTPUTFILE=%OUTPUTFILE%

rem if the specified tracelogfile does not exist, display an error message and give up
if not exist %TRACEFILE% (
	echo The tracelogfile %TRACEFILE% does not exist. exiting ...
	call :HELP
	goto :EOF
)

rem if the specified moffile does not exist, display an error message and give up
if not exist %MOFFILE% (
	echo The moffile %MOFFILE% does not exist. exiting ...
	call :HELP
	goto :EOF
)

rem set a variable for output file with extension
set OUTPUTFILEWITHEXT=%OUTPUTFILE%.csv
%TRACE% The value of variable OUTPUTFILEWITHEXT=%OUTPUTFILEWITHEXT%


rem if the specified outputfile exists, ask if the user is ok with it being over-written. 
rem if the user wants to continue, delete the old output file, else give up.
if exist %OUTPUTFILEWITHEXT% (
	echo The file %OUTPUTFILEWITHEXT% already exists. You may press Control-C to terminate the batch file. Continuing the batch file will overwrite this file.
	Pause
	del %OUTPUTFILEWITHEXT% 1>nul 2>nul
)

rem if the old error file exists, delete it
if exist %ERRORFILE% (
	del %ERRORFILE% 1>nul 2>nul
	%TRACE% Deleted the file %ERRORFILE%
)

rem call the utility with the right arguments
%TRACE% About to call the utility tracerpt.exe ...

if "%USE_TRACE_FMT%"=="0" (goto :USE_TRACEPRT_UTILITY) else (goto :USE_TRACEFMT_UTILITY)

:USE_TRACEPRT_UTILITY
%TRACE% Entered the USE_TRACEPRT_UTILITY block, about to call traceprt
tracerpt %TRACEFILE% -o %OUTPUTFILE% -mof %MOFFILE% > %ERRORFILE% 2>&1 
rem if output file does not exist, display an error message and give up
if not exist %OUTPUTFILEWITHEXT% (
	%TRACE% The file %OUTPUTFILEWITHEXT% does not exist, therefore exiting ...
	call :DISPLAY_ERROR_MESSAGE 
	goto :EOF
)
notepad %OUTPUTFILEWITHEXT%
goto :EOF

:USE_TRACEFMT_UTILITY
%TRACE% Entered the USE_TRACEFMT_UTILITY block, about to call tracefmt
tracefmt %TRACEFILE% -o %OUTPUTFILEWITHEXT% -tmf %MOFFILE%  -nosummary > %ERRORFILE% 2>&1 
rem if output file does not exist, display an error message and give up
if not exist %OUTPUTFILEWITHEXT% (
	%TRACE% The file %OUTPUTFILEWITHEXT% does not exist, therefore exiting ...
	call :DISPLAY_ERROR_MESSAGE 
	goto :EOF
)
notepad %OUTPUTFILEWITHEXT%
goto :EOF



goto :EOF
rem *************** end of 'main'




rem *************** Procedures begin here ****************************

rem *************** start of procedure VALIDATE
:VALIDATE

set ARG=1
set SWHELPFOUND=0
set SWMODEFOUND=0
set SWTRACELOGFOUND=0
set SWMOFFOUND=0
set SWOUTPUTFOUND=0
set OUTNAMENAME=0

rem If no arguments are used at all, don't perform any other validation, just display help and give up
if %CMDARGCOUNT% EQU 0 if %CMDSWCOUNT% EQU 0 (call :HELP) & (goto :EOF)

rem If not arguments are given, display help
if %CMDARGCOUNT% GTR 0 goto ERROR_USED_ARGUMENTS_WITHOUT_SWITCHES
	
rem If the switch SWHELP is used anywhere, don't perform any other validation, just display help and give up
call :MYFINDSWITCH %SWHELP%
if not "%RET%"=="0" (call :HELP) & (goto :EOF)

:SWLOOP                                                                                                                     
	if %ARG% GTR %CMDSWCOUNT% goto :SWLOOPEND
	call :GETSWITCH %ARG%
	set MYSWITCH=%RET:~1%
	
	rem make sure no switch is used twice
	if /i "%MYSWITCH%"=="%SWHELP%" (if "%SWHELPFOUND%"=="1" (goto ERROR_USED_SAME_SWITCH_TWICE) else (set SWHELPFOUND=1))
	if /i "%MYSWITCH%"=="%SWMODE%" (if "%SWMODEFOUND%"=="1" (goto ERROR_USED_SAME_SWITCH_TWICE) else (set SWMODEFOUND=1))
	if /i "%MYSWITCH%"=="%SWTRACELOG%" (if "%SWTRACELOGFOUND%"=="1" (goto ERROR_USED_SAME_SWITCH_TWICE) else (set SWTRACELOGFOUND=1))
	if /i "%MYSWITCH%"=="%SWMOF%" (if "%SWMOFFOUND%"=="1" (goto ERROR_USED_SAME_SWITCH_TWICE) else (set SWMOFFOUND=1))
	if /i "%MYSWITCH%"=="%SWOUTPUT%" (if "%SWOUTPUTFOUND%"=="1" (goto ERROR_USED_SAME_SWITCH_TWICE) else (set SWOUTPUTFOUND=1))
	
	rem make sure that the switches mode and tracelog are not used simultaneously
	if "%SWMODEFOUND%"=="1" if "%SWTRACELOGFOUND%"=="1" goto ERROR_USED_BOTH_MODE_AND_TRACELOG
	
	rem make sure that there is no switch outside our list
	if /i not "%MYSWITCH%"=="%SWHELP%" (
		if /i not "%MYSWITCH%"=="%SWMODE%" (
			if /i not "%MYSWITCH%"=="%SWTRACELOG%" (
				if /i not "%MYSWITCH%"=="%SWMOF%" (
					if /i not "%MYSWITCH%"=="%SWOUTPUT%" (
						(echo Invalid Switch "%RET%") & (call :HELP) & (goto :EOF) )))))
	set /a ARG+=1
goto :SWLOOP
:SWLOOPEND

rem make sure that either the switch "-mode" or "-tracelog" was used
if "%SWMODEFOUND%"=="0" if "%SWTRACELOGFOUND%"=="0" (echo Invalid Usage : neither "-%SWMODE%" nor "-%SWTRACELOG%" was specified) & (call :HELP) & (goto :EOF)

rem make sure that the value of the mode entered is valid
call :MYFINDSWITCH %SWMODE%
if not "%RET%"=="0" if not "%RETV%"=="1" if not "%RETV%"=="2" goto ERROR_INVALID_MODE

rem make sure that the value of the outputfile entered does not have any extension
call :MYFINDSWITCH %SWOUTPUT%
for /f "tokens=1* delims=." %%I in ("%RETV%") do (set OUTPUTEXT=%%J)
if not "%OUTPUTEXT%"=="" goto ERROR_USED_OUTPUTFILENAME_WITH_EXTENSION

rem if we have come this far, everything went well, set the valid flag
set VALID=1
goto :EOF

:ERROR_USED_SAME_SWITCH_TWICE
(echo Invalid Usage : use the switch %RET% multiple times) & (call :HELP) & (goto :EOF)

:ERROR_USED_BOTH_MODE_AND_TRACELOG
(echo Invalid Usage : cannot use both "-%SWMODE%" and "-%SWTRACELOG%" at the same time) & (call :HELP) & (goto :EOF)

:ERROR_USED_ARGUMENTS_WITHOUT_SWITCHES
call :GETARG 1
echo Invalid Usage : "%RET%" used without any switch
call :HELP
goto :EOF

:ERROR_INVALID_MODE
(echo Invalid Usage : Valid values for %SWMODE% are 1 and 2) & (call :HELP) & (goto :EOF)

:ERROR_USED_OUTPUTFILENAME_WITH_EXTENSION
(echo Invalid Usage : Output filename should not have any extension) & (call :HELP) & (goto :EOF)

rem *************** end of procedure VALIDATE

rem *************** start of procedure HELP
:HELP
echo Usage
echo "msdtcvtr { -MODE {1 | 2} | -tracelog tracelogfilename } [options]"
echo "All switches can be prefixed with either '-' or '/'"
echo Parameters:
echo    "-MODE 1          to view background tracing"
echo    "-MODE 2          to view tracing generated by ui"
echo    "-tracelog <file> binary Trace log file name"
echo Options:
echo    "-h  OR -?        Display Help"
echo    "-o <filename>    Output Filename without extension"
echo    "-mof <filename>  Mof Filename"
goto :EOF
rem *************** end of procedure HELP


rem *************** start of procedure DISPLAY_ERROR_MESSAGE
:DISPLAY_ERROR_MESSAGE
echo Failed to convert the binary trace data to text format.
echo Following reasons can cause this to happen:
echo 1) The utility TraceFmt.exe is missing 
echo 2) The file %TRACEFILE% is either missing or corrupted
echo 3) The file %MOFFILE% is either missing or corrupted
echo The exact error message can be found in the file '%ERRORFILE%'
goto :EOF
rem *************** end of procedure DISPLAY_ERROR_MESSAGE


rem /////////////////////////////////////////////////////////////////////////
rem INIT procedure
rem Must be called in local state before other procs are used
rem
:INIT
%TRACE% [proc %0 %*]

goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem VARDEL procedure
rem Delete multiple variables by prefix
rem
rem Arguments:	%1=variable name prefix
rem
:VARDEL
%TRACE% [proc %0 %*]
	for /f "tokens=1 delims==" %%I in ('set %1 2^>nul') do set %%I=
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem PARSECMDLINE procedure
rem Parse a command line into switches and args
rem
rem Arguments:	CMDLINE=command text to parse
rem		%1=0 for new parse (def) or 1 to append to existing
rem
rem Returns:	CMDARG_n=arguments, CMDSW_n=switches
rem		CMDARGCOUNT=arg count, CMDSWCOUNT=switch count
rem		RET=total number of args processed
rem
:PARSECMDLINE
%TRACE% [proc %0 %*]
	if not {%1}=={1} (
		(call :VARDEL CMDARG_)
		(call :VARDEL CMDSW_)
		(set /a CMDARGCOUNT=0)
		(set /a CMDSWCOUNT=0)
	)
	set /a RET=0
	call :PARSECMDLINE1 %CMDLINE% 1>nul
	set _MTPLIB_T1=
	set _LASTARGSWITCH=0
	set _LASTARGSWITCHNAME=0
goto :EOF
:PARSECMDLINE1
	if {%1}=={} goto :EOF
	set _MTPLIB_T1=%1
	set _MTPLIB_T1=%_MTPLIB_T1:"=%
	set /a RET+=1
	shift /1
	if "%_MTPLIB_T1:~0,1%"=="/" goto :PARSECMDLINESW
	if "%_MTPLIB_T1:~0,1%"=="-" goto :PARSECMDLINESW
	if "%_LASTARGSWITCH%"=="1" (
		set CMDSW_%CMDSWCOUNT%=%_LASTARGSWITCHNAME%:%_MTPLIB_T1%
		set _LASTARGSWITCH=0
		goto :PARSECMDLINE1
	) 
	set /a CMDARGCOUNT+=1
	set CMDARG_%CMDARGCOUNT%=%_MTPLIB_T1%
	set _LASTARGSWITCH=0
	goto :PARSECMDLINE1
	:PARSECMDLINESW
	set /a CMDSWCOUNT+=1
	set CMDSW_%CMDSWCOUNT%=%_MTPLIB_T1%
	set _LASTARGSWITCH=1
	set _LASTARGSWITCHNAME=%_MTPLIB_T1%
	goto :PARSECMDLINE1
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem GETARG procedure
rem Get a parsed argument by index
rem
rem Arguments:	%1=argument index (1st arg has index 1)
rem
rem Returns:	RET=argument text or empty if no argument
rem
:GETARG
%TRACE% [proc %0 %*]
	set RET=
	if %1 GTR %CMDARGCOUNT% goto :EOF
	if %1 EQU 0 goto :EOF
	if not defined CMDARG_%1 goto :EOF
	set RET=%%CMDARG_%1%%
	call :RESOLVE
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem GETSWITCH procedure
rem Get a switch argument by index
rem
rem Arguments:	%1=switch index (1st switch has index 1)
rem
rem Returns:	RET=switch text or empty if none
rem		RETV=switch value (after colon char) or empty
rem
:GETSWITCH
%TRACE% [proc %0 %*]
	(set RET=) & (set RETV=)
	if %1 GTR %CMDSWCOUNT% goto :EOF
	if %1 EQU 0 goto :EOF
	if not defined CMDSW_%1 goto :EOF
	set RET=%%CMDSW_%1%%
	call :RESOLVE
	for /f "tokens=1* delims=:" %%I in ("%RET%") do (set RET=%%I) & (set RETV=%%J)
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem FINDSWITCH procedure
rem Finds the index of the named switch
rem
rem Arguments:	%1=switch name
rem		%2=search start index (def: 1)
rem
rem Returns:	RET=index (0 if not found)
rem		RETV=switch value (text after colon)
rem
:FINDSWITCH
%TRACE% [proc %0 %*]
	if {%2}=={} (set /a _MTPLIB_T4=1) else (set /a _MTPLIB_T4=%2)
	:FINDSWITCHLOOP
		call :GETSWITCH %_MTPLIB_T4%
		if "%RET%"=="" (set RET=0) & (goto :FINDSWITCHEND)
		if /i "%RET%"=="%1" (set RET=%_MTPLIB_T4%) & (goto :FINDSWITCHEND)
		set /a _MTPLIB_T4+=1
	goto :FINDSWITCHLOOP
	:FINDSWITCHEND
	set _MTPLIB_T4=
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem MYFINDSWITCH procedure
rem Finds the index of the named switch
rem
rem Arguments:	%1=switch name without the leading / or -
rem		%2=search start index (def: 1)
rem
rem Returns:	RET=index (0 if not found)
rem		RETV=switch value (text after colon)
rem
:MYFINDSWITCH
%TRACE% [proc %0 %*]
	if {%2}=={} (set /a _MTPLIB_T4=1) else (set /a _MTPLIB_T4=%2)
	:MYFINDSWITCHLOOP
		call :GETSWITCH %_MTPLIB_T4%
		if "%RET%"=="" (set RET=0) & (goto :MYFINDSWITCHEND)
		if /i "%RET:~1%"=="%1" (set RET=%_MTPLIB_T4%) & (goto :MYFINDSWITCHEND)
		set /a _MTPLIB_T4+=1
	goto :MYFINDSWITCHLOOP
	:MYFINDSWITCHEND
	set _MTPLIB_T4=
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem REGSETM and REGSETU procedures
rem Set registry values from variables
rem
rem Arguments:	%1=reg context (usually script name)
rem		%2=variable to save (or prefix to save set of vars)
rem
:REGSETM
%TRACE% [proc %0 %*]
	for /f "tokens=1* delims==" %%I in ('set %2 2^>nul') do call :REGSET1 HKLM %1 %%I "%%J"
goto :EOF
:REGSETU
%TRACE% [proc %0 %*]
	for /f "tokens=1* delims==" %%I in ('set %2 2^>nul') do call :REGSET1 HKCU %1 %%I "%%J"
goto :EOF
:REGSET1
	set _MTPLIB_T10=%4
	set _MTPLIB_T10=%_MTPLIB_T10:\=\\%
	reg add %1\Software\MTPScriptContexts\%2\%3=%_MTPLIB_T10% >nul
	reg update %1\Software\MTPScriptContexts\%2\%3=%_MTPLIB_T10% >nul
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem REGGETM and REGGETU procedures
rem Get registry value or values to variables
rem
rem Arguments:	%1=reg context (usually script name)
rem		%2=variable to restore (def: restore entire context)
rem
rem Returns:	RET=value of last variable loaded
rem
rem WARNING:	The "delims" value in the FOR commands below is a TAB
rem		character, followed by a space. If this file is edited by
rem		an editor which converts tabs to spaces, this procedure
rem		will break!!!!!
rem
:REGGETM
%TRACE% [proc %0 %*]
	for /f "delims=	 tokens=2*" %%I in ('reg query HKLM\Software\MTPScriptContexts\%1\%2 ^|find "REG_SZ"') do call :REGGETM1 %%I "%%J"
goto :EOF
:REGGETU
%TRACE% [proc %0 %*]
	for /f "delims=	 tokens=2*" %%I in ('reg query HKCU\Software\MTPScriptContexts\%1\%2 ^|find "REG_SZ"') do call :REGGETM1 %%I "%%J"
goto :EOF
:REGGETM1
	set _MTPLIB_T10=%2
	set _MTPLIB_T10=%_MTPLIB_T10:\\=\%
	set _MTPLIB_T10=%_MTPLIB_T10:"=%
	set %1=%_MTPLIB_T10%
	set RET=%_MTPLIB_T10%
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem REGDELM and REGDELU procedures
rem Delete registry values
rem
rem Arguments:	%1=reg context (usually script name)
rem		%2=variable to delete (def: delete entire context)
rem
:REGDELM
%TRACE% [proc %0 %*]
	call :GETTEMPNAME
	echo y >%RET%
	reg delete HKLM\Software\MTPScriptContexts\%1\%2 <%RET% >nul
	del %RET%
goto :EOF
:REGDELU
%TRACE% [proc %0 %*]
	call :GETTEMPNAME
	echo y >%RET%
	reg delete HKCU\Software\MTPScriptContexts\%1\%2 <%RET% >nul
	del %RET%
goto :EOF


rem /////////////////////////////////////////////////////////////////////////
rem SRAND procedure
rem Seed the random number generator
rem
rem Arguments:	%1=new seed value
rem
:SRAND
%TRACE% [proc %0 %*]
	set /a _MTPLIB_NEXTRAND=%1
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem RAND procedure
rem Get next random number (0 to 32767)
rem
rem Returns:	RET=next random number
rem
:RAND
%TRACE% [proc %0 %*]
	if not defined _MTPLIB_NEXTRAND set /a _MTPLIB_NEXTRAND=1
	set /a _MTPLIB_NEXTRAND=_MTPLIB_NEXTRAND * 214013 + 2531011
	set /a RET=_MTPLIB_NEXTRAND ^>^> 16 ^& 0x7FFF
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem RESOLVE procedure
rem Fully resolve all indirect variable references in RET variable
rem
rem Arguments:	RET=value to resolve
rem
rem Returns:	RET=as passed in, with references resolved
rem
:RESOLVE
%TRACE% [proc %0 %*]
	:RESOLVELOOP
		if "%RET%"=="" goto :EOF
		set RET1=%RET%
		for /f "tokens=*" %%I in ('echo %RET%') do set RET=%%I
	if not "%RET%"=="%RET1%" goto :RESOLVELOOP
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem GETINPUTLINE procedure
rem Get a single line of keyboard input
rem
rem Returns:	RET=Entered line
rem
:GETINPUTLINE
%TRACE% [proc %0 %*]
	call :GETTEMPNAME
	set _MTPLIB_T1=%RET%
	copy con "%_MTPLIB_T1%" >nul
	for /f "tokens=*" %%I in ('type "%_MTPLIB_T1%"') do set RET=%%I
	if exist "%_MTPLIB_T1%" del "%_MTPLIB_T1%"
	set _MTPLIB_T1=
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem GETSYNCFILE procedure
rem Get a sync file name (file will not exist)
rem
rem Returns:	RET=Name of sync file to use
rem
:GETSYNCFILE
%TRACE% [proc %0 %*]
	call :GETTEMPNAME
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem SETSYNCFILE procedure
rem Flag sync event (creates the file)
rem
rem Arguments:	%1=sync filename to flag
rem
:SETSYNCFILE
%TRACE% [proc %0 %*]
	echo . >%1
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem DELSYNCFILE procedure
rem Delete sync file
rem
rem Arguments:	%1=sync filename
rem
:DELSYNCFILE
%TRACE% [proc %0 %*]
	if exist %1 del %1
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem WAITSYNCFILE
rem Wait for sync file to flag
rem
rem Arguments:	%1=sync filename
rem		%2=timeout in seconds (def: 60)
rem
rem Returns:	RET=Timeout remaining, or 0 if timeout
rem
:WAITSYNCFILE
%TRACE% [proc %0 %*]
	if {%2}=={} (set /a RET=60) else (set /a RET=%2)
	if exist %1 goto :EOF
	:WAITSYNCFILELOOP
		sleep 1
		set /a RET-=1
	if %RET% GTR 0 if not exist %1 goto :WAITSYNCFILELOOP
goto :EOF

rem /////////////////////////////////////////////////////////////////////////
rem GETTEMPNAME procedure
rem Create a temporary file name
rem
rem Returns:	RET=Temporary file name
rem
:GETTEMPNAME
%TRACE% [proc %0 %*]
	if not defined _MTPLIB_NEXTTEMP set /a _MTPLIB_NEXTTEMP=1
	if defined TEMP (
		(set RET=%TEMP%)
	) else if defined TMP (
		(set RET=%TMP%)
	) else (set RET=%SystemRoot%)
	:GETTEMPNAMELOOP
		set /a _MTPLIB_NEXTTEMP=_MTPLIB_NEXTTEMP * 214013 + 2531011
		set /a _MTPLIB_T1=_MTPLIB_NEXTTEMP ^>^> 16 ^& 0x7FFF
		set RET=%RET%\~SH%_MTPLIB_T1%.tmp
	if exist "%RET%" goto :GETTEMPNAMELOOP
	set _MTPLIB_T1=
goto :EOF

rem These must be the FINAL LINES in the script...
:DOSEXIT
echo This script requires Windows NT

rem /////////////////////////////////////////////////////////////////////////






