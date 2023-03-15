@echo off 
set len = 3 
set obj[0].Name = Joe 
set obj[0].ID = 1 
set obj[1].Name = Mark 
set obj[1].ID = 2 
set obj[2].Name = Mohan 
set obj[2].ID = 3 
set i = 0 
:loop 

if %i% equ %len% goto :eof 
set cur.Name= 
set cur.ID=

for /f "usebackq delims==.tokens=1-3" %%j in (`set obj[%i%]`) do ( 
   set cur.%%k=%%l 
) 
echo Name = %cur.Name% 
echo Value = %cur.ID% 
set /a i = %i%+1 
goto loop
