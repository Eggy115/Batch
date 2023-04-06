xcopy c:\"program files (x86)"\pstools\psloglist.exe \\%1\c$\windows\system32\
psexec \\%1 -u corp\jlprice psloglist -d 5 > ACSR_sys.txt 

