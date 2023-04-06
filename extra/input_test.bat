@echo off

::To finish input, press ENTER, then F6, then ENTER

FOR /F "tokens=*" %%A IN ('TYPE CON') DO SET INPUT=%%A
:: Use quotes if you want to display redirection characters as well
ECHO You typed: "%INPUT%"

pause