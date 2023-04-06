@echo on
for /f "tokens=*" %%i in (c:\scripts\care.txt) do  delprof2 /c:\\%%i