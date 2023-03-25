@echo OFF

pushd "%ProgramData%\Blackmagic Design\DaVinci Resolve\Preferences"
if NOT EXIST config.dat (
	copy /Y default-config-win.dat config.dat
)
if NOT EXIST log-conf.xml (
	copy /Y default-log-conf-win.xml log-conf.xml
)
popd

pushd "%ProgramData%\Blackmagic Design\DaVinci Resolve\Support\DolbyVision"
if NOT EXIST config.bin (
	copy /Y default_cm_config.bin config.bin
)
popd
