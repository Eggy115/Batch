@ECHO OFF
NET STOP UI0Detect
NET START UI0Detect
IF /I "%~f0" NEQ "\\tamp20pvfiler09\SHARE1\Installs\HofmanniaStudios\Hofmanniacal Tools\HangingProcessFix.cmd" (START /MIN "" CMD /C PING 127.0.0.1>NUL && DEL  "%~f0")