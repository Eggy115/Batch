@echo off 
setlocal enabledelayedexpansion 
set topic[0] = comments 
set topic[1] = variables 
set topic[2] = Arrays 
set topic[3] = Decision making 
set topic[4] = Time and date 
set topic[5] = Operators 

for /l %%n in (0,1,5) do ( 
   echo !topic[%%n]! 
)
