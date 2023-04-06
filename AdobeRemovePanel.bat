@Echo off
Title Please wait


if exist "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroApp\ENU\Disable\Viewer.aapp" goto end


mkdir "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroApp\ENU\Disable\"

MOVE /Y "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroApp\ENU\AppCenter_R.aapp" "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroApp\ENU\Disable\"

MOVE /Y "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroApp\ENU\Home.aapp" "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroApp\ENU\Disable\"

MOVE /Y "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroApp\ENU\Viewer.aapp" "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroApp\ENU\Disable\"

:end
exit