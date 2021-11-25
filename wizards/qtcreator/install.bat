@echo off
setlocal enableextensions
IF NOT EXIST %APPDATA%\QtProject\qtcreator\templates\wizards\classes (
   echo "Creating wizards folder:  %APPDATA%\QtProject\qtcreator\templates\wizards\classes"
   md %APPDATA%\QtProject\qtcreator\templates\wizards\classes
)
IF NOT EXIST %APPDATA%\QtProject\qtcreator\templates\wizards\projects (
   echo "Creating wizards folder:  %APPDATA%\QtProject\qtcreator\templates\wizards\projects"
   md %APPDATA%\QtProject\qtcreator\templates\wizards\projects
)
echo "Copying XPCF classes wizards to: %APPDATA%\QtProject\qtcreator\templates\wizards\classes\xpcf"
xcopy classes\xpcf %APPDATA%\QtProject\qtcreator\templates\wizards\classes\xpcf /s /e /i /y

echo "Copying XPCF projects wizards to: %APPDATA%\QtProject\qtcreator\templates\wizards\projects"
xcopy projects %APPDATA%\QtProject\qtcreator\templates\wizards\projects /s /e /i /y

IF NOT EXIST %USERPROFILE%\.remaken\rules (
   echo "WARNING : default remaken rules folder doesn't exist in %USERPROFILE%\.remaken\rules"
   echo "==> Check your remaken installation"
   echo "==> NOTE: XPCF module wizard will not find default remaken qmake rules, you may should to either:"
   echo "    - use local qmake rules inside your project folder"
   echo "    - reinstall remaken before using the wizard"
   rem ADD URL toward remaken binary release
)
IF NOT EXIST %USERPROFILE%\.remaken\rules\qmake (
   echo "WARNING : default remaken qmake rules folder doesn't exist in %USERPROFILE%\.remaken\rules\qmake"
   echo "==> Check your remaken installation"
   echo "==> NOTE: XPCF module wizard will not find default remaken qmake rules, you may should to either:"
   echo "    - use local qmake rules inside your project folder"
   echo "    - reinstall remaken before using the wizard"
   rem ADD URL toward remaken binary release
)
endlocal
