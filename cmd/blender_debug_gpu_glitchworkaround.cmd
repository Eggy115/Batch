@echo off
echo Starting blender with GPU debugging and glitch workaround options, log files 
echo will be created in your temp folder, windows explorer will open after you 
echo close blender to help you find them.
echo.
echo If you report a bug on https://developer.blender.org you can attach these files
echo by dragging them into the text area of your bug report, please include both
echo blender_debug_output.txt and blender_system_info.txt in your report. 
echo.
pause
mkdir "%temp%\blender\debug_logs" > NUL 2>&1
echo.
echo Starting blender and waiting for it to exit....
set PYTHONPATH=
"%~dp0\blender" --debug --debug-gpu --debug-gpu-force-workarounds --python-expr "import bpy; bpy.ops.wm.sysinfo(filepath=r'%temp%\blender\debug_logs\blender_system_info.txt')" > "%temp%\blender\debug_logs\blender_debug_output.txt" 2>&1 < %0
explorer "%temp%\blender\debug_logs"