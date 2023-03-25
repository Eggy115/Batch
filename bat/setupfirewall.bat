@echo OFF

SET RESOLVEBIN=%~1

netsh advfirewall firewall delete rule name="DaVinciResolve"
netsh advfirewall firewall add rule name="DaVinciResolve" profile=Private dir=in action=allow program="%RESOLVEBIN%Resolve.exe" enable=yes

netsh advfirewall firewall delete rule name="DaVinciResolveBmdpaneld"
netsh advfirewall firewall add rule name="DaVinciResolveBmdpaneld" profile=Private dir=in action=allow program="%RESOLVEBIN%bmdpaneld.exe" enable=yes

netsh advfirewall firewall delete rule name="DaVinciResolvePanel"
netsh advfirewall firewall add rule name="DaVinciResolvePanel" profile=Private dir=in action=allow program="%RESOLVEBIN%DaVinciPanelDaemon.exe" enable=yes

netsh advfirewall firewall delete rule name="DaVinciResolveJLCooper"
netsh advfirewall firewall add rule name="DaVinciResolveJLCooper" profile=Private dir=in action=allow program="%RESOLVEBIN%JLCooperPanelDaemon.exe" enable=yes

netsh advfirewall firewall delete rule name="DaVinciResolveEuphonix"
netsh advfirewall firewall add rule name="DaVinciResolveEuphonix" profile=Private dir=in action=allow program="%RESOLVEBIN%EuphonixPanelDaemon.exe" enable=yes

netsh advfirewall firewall delete rule name="DaVinciResolveTangent"
netsh advfirewall firewall add rule name="DaVinciResolveTangent" profile=Private dir=in action=allow program="%RESOLVEBIN%TangentPanelDaemon.exe" enable=yes

netsh advfirewall firewall delete rule name="DaVinciResolveElements"
netsh advfirewall firewall add rule name="DaVinciResolveElements" profile=Private dir=in action=allow program="%RESOLVEBIN%ElementsPanelDaemon.exe" enable=yes

REM Remove legacy rule for oxygen panel daemon if it is there
netsh advfirewall firewall delete rule name="DaVinciResolveOxygen"

netsh advfirewall firewall delete rule name="DaVinciResolveFuScript"
netsh advfirewall firewall add rule name="DaVinciResolveFuScript" profile=Private dir=in action=allow program="%RESOLVEBIN%fuscript.exe" enable=yes

REM Remove legacy rule for DPDecoder.exe, QtDecoder.exe if it is there
netsh advfirewall firewall delete rule name="DaVinciResolveDpdecoder"
netsh advfirewall firewall delete rule name="DaVinciResolveQtdecoder"
