@echo off
echo.
echo Custom PS Tools for Brad Clark:
echo.
echo PSACSR Syntax: psacsr tbhilb#####
echo 	Usage: Calls \\tbhilms1\install$\acsr.bat to silently upgrade the 
echo           ACSR install utility to WCCAD.  Requires user to be out of ACSR.
echo.
echo PSCTI Syntax: pscti tbhilb#####
echo 	Usage: Forces CTI (re)install.  Calls \\tbhilms1\install$\cti_force.bat
echo           which installs without checking for an installation log.
echo.
echo PSXPBC Syntax: psxpbc tbhilb##### 
echo 	Usage: Logon to specified machine at the command prompt
echo.
echo PUSHOFFICE07 Syntax: pushoffice07 tbhilb##### 
echo 	Usage: Calls the Upgrade.bat file from Office 2007 Enterprise edition
echo           and installs it remotely and silently to the specified machine name.
echo.
echo PSREBOOT Syntax: psreboot tbhilb##### [seconds]
echo 	Usage: Restarts the system with an information screen indicating who initiated
echo           the restart and a countdown timer Ex: psreboot tbhilb12345 10 will 
echo           restart the system after displaying a message box for 10 seconds.
echo.
echo UPGRADEVNC Syntax: upgradevnc tbhilb#####
echo 	Usage: Calls \\tbhilms1\install$\VNC\UltraVNC\UltraVNC\_upgrade.bat
echo           which upgrades from WinVNC to UltraVNC silently. Useful for upgrading
echo           to see a user's 2nd monitor
ECHO.
echo DELPROFILES Syntax: delprofiles tbhilb#####
echo 	Usage: Runs the DELPROF.EXE program to delete profiles that have not been used 
echo           within the last 10 days.  Useful for cleaning up Cust Svc machines, etc.
ECHO.
echo PSGROUPLIST Syntax: psgrouplist "TB HIL Some Group Name"
echo 	Usage: Runs the command NET GROUP /DOMAIN on the group and lists the group members. 
echo           The group name must be in quotes, even if there are no spaces in the name.
ECHO.
ECHO ECHO SCROLL UP TO SEE PREVIOUS COMMANDS
echo.
echo Other PSTOOLS (use /? after other tools for syntax):
echo.
echo PSFILE		PSGETSID	PSINFO		PSKILL		PSLIST	
ECHO PSLOGGEDON	PSLOGLIST	PSPASSWD	PSSERVICE	PSSUSPEND
ECHO PSUPTIME
ECHO ACSR Tools:  ACSRHIL   ACSRDIV   ACSRMAN   ACSRPIN   ACSRTRI
ECHO.
