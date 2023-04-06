::Name 
::Author John Hofmann
::Version 1.0
::Date ECHO %DATE:~4%
::
::Changelog
::
::
::Known Issues
::

@ECHO OFF
IF NOT #%MAXIMIZED%# EQU #MAXIMIZED# (
	SET "MAXIMIZED=MAXIMIZED"
	START /MAX "%~n0" %0
	EXIT 1
)
MODE CON COLS=400
CMD /C "EXIT 82"
ECHO %%ALLUSERSPROFILE%%                    %ALLUSERSPROFILE%
ECHO %%APPDATA%%                            %APPDATA%
ECHO %%CD%%                                 %CD%
ECHO %%ClientName%%                         %ClientName%
ECHO %%CMDEXTVERSION%%                      %CMDEXTVERSION%
ECHO %%CMDCMDLINE%%                         %CMDCMDLINE%
ECHO %%CommonProgramFiles%%                 %CommonProgramFiles%
ECHO %%COMMONPROGRAMFILES(x86)%%            %COMMONPROGRAMFILES(x86)%
ECHO %%COMPUTERNAME%%                       %COMPUTERNAME%
ECHO %%COMSPEC%%                            %COMSPEC%
ECHO %%DATE%%                               %DATE%
ECHO %%ERRORLEVEL%%                         %ERRORLEVEL%
ECHO %%FPS_BROWSER_APP_PROFILE_STRING%%     %FPS_BROWSER_APP_PROFILE_STRING%
ECHO %%FPS_BROWSER_USER_PROFILE_STRING%%    %FPS_BROWSER_USER_PROFILE_STRING%
ECHO %%HighestNumaNodeNumber%%              %HighestNumaNodeNumber%
ECHO %%HOMEDRIVE%%                          %HOMEDRIVE%
ECHO %%HOMEPATH%%                           %HOMEPATH%
ECHO %%LOCALAPPDATA%%                       %LOCALAPPDATA%
ECHO %%LOGONSERVER%%                        %LOGONSERVER%
ECHO %%NUMBER_OF_PROCESSORS%%               %NUMBER_OF_PROCESSORS%
ECHO %%OS%%                                 %OS%
ECHO %%PATH%%                               %PATH%
ECHO %%PATHEXT%%                             %PATHEXT%
ECHO %%PROCESSOR_ARCHITECTURE%%             %PROCESSOR_ARCHITECTURE%
ECHO %%PROCESSOR_ARCHITEW6432%%             %PROCESSOR_ARCHITEW6432%
ECHO %%PROCESSOR_IDENTIFIER%%               %PROCESSOR_IDENTIFIER%
ECHO %%PROCESSOR_LEVEL%%                    %PROCESSOR_LEVEL%
ECHO %%PROCESSOR_REVISION%%                 %PROCESSOR_REVISION%
ECHO %%ProgramW6432%%                       %ProgramW6432%
ECHO %%ProgramData%%                        %ProgramData%
ECHO %%ProgramFiles%%                       %ProgramFiles%
ECHO %%ProgramFiles(x86)%%                  %ProgramFiles(x86)%
ECHO %%PROMPT%%                             %PROMPT%
ECHO %%PSModulePath%%                       %PSModulePath%
ECHO %%Public%%                             %Public%
ECHO %%RANDOM%%                             %RANDOM%
ECHO %%SessionName%%                        %SessionName%
ECHO %%SYSTEMDRIVE%%                        %SYSTEMDRIVE%
ECHO %%SYSTEMROOT%%                         %SYSTEMROOT%
ECHO %%TEMP%%                               %TEMP%
ECHO %%TMP%%                                %TMP%
ECHO %%TIME%%                               %TIME%
ECHO %%UserDnsDomain%%                      %UserDnsDomain%
ECHO %%USERDOMAIN%%                         %USERDOMAIN%
ECHO %%USERDOMAIN_roamingprofile%%          %USERDOMAIN_roamingprofile%
ECHO %%USERNAME%%                           %USERNAME%
ECHO %%USERPROFILE%%                        %USERPROFILE%
ECHO %%WINDIR%%                             %WINDIR%
ECHO %%__APPDIR__%%                         %__APPDIR__%
ECHO %%__CD__%%                             %__CD__%
ECHO %%=C:%%                                %=C:%
ECHO %%=D:%%                                %=D:%
ECHO %%DPATH%%                              %DPATH%
ECHO %%=ExitCode%%                          %=ExitCode%
ECHO %%=ExitCodeAscii%%                     %=ExitCodeAscii%
ECHO %%FIRMWARE_TYPE%%                      %FIRMWARE_TYPE%
ECHO %%KEYS%%                               %KEYS%