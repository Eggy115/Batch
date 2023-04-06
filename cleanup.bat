@echo off
setlocal

@for /d %%d in ( "C:Documents and Settings*" ) do @(
  echo %%d
  if exist "%%dLocal Settings" (
    if exist "%%dLocal SettingsTemp" (
      for /d %%e in ( "%%dLocal SettingsTemp*" ) do @(
        attrib -R -A -S -H "%%e*.*"
        rmdir "%%e" /s /q
      )
      if exist "%%dLocal SettingsTemp*.*" (
        attrib -R -A -S -H "%%dLocal SettingsTemp*.*"
        del "%%dLocal SettingsTemp*.*" /q
      )
    )
  )
)