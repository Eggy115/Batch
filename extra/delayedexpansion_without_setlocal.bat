@echo off

::setting enable to 1 enables delayedexpansion, 0 disables it
set enable=1

::This line enables delayedexpansion without setlocal. Changes dont come into effect until starting a new cmd
reg add "HKLM\Software\Microsoft\Command Processor" /v "DelayedExpansion" /t REG_DWORD /d %enable% 0 /f
