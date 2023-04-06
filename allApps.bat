@echo off 
Rem This is for listing down all the files in the directory Program files 
dir "C:\Program Files" >lists.txt
dir "C:\Program Files (x86)" >lists86.txt
 
echo "The program has completed"

pause
