


!include "GetTime.nsh"

;--------------------------------
;Include Modern UI

!include "MUI2.nsh"

;--------------------------------
;General

  Name "${SETUP_PRODUCTNAME} Installer"
  InstallDir "${SETUP_INSTALLDIR}"
  SetFont "Verdana" 9
   
  Var "AppName"
  Var "AppGuid"
  Var "AppVersion"
  Var "UnInstallName"
  Var "SetupInstallDir"

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  !define MUI_ICON "logo.ico"
  !define MUI_UNICON "logo.ico"

;--------------------------------
;Pages
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"

  Function .onInit
 
  SetRegView 64
  ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SETUP_GUID}" "UninstallString"
  StrCmp $R0 "" done
 
  MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
  "${SETUP_PRODUCTNAME} is already installed. $\n$\nClick `OK` to remove the \
  previous version or `Cancel` to cancel this upgrade." \
  IDOK uninst
  Abort
 
;Run the uninstaller
uninst:
  ClearErrors
  ExecWait '$R0' ;Do not copy the uninstaller to a temp file
 
  IfErrors no_remove_uninstaller done
    ;You can either use Delete /REBOOTOK in the uninstaller or add some code
    ;here to remove the uninstaller. Use a registry key to check
    ;whether the user has chosen to uninstall. If you are using an uninstaller
    ;components page, make sure all sections are uninstalled.
  no_remove_uninstaller:
 
done:
 
FunctionEnd 
;--------------------------------
;Installer Sections
Section "PreAddRemoveProgramRegistry"
  SetOutPath "$INSTDIR"
  StrCpy $AppName "${SETUP_PRODUCTNAME}"
  StrCpy $AppGuid "${SETUP_GUID}"
  StrCpy $AppVersion "${SETUP_VERSION}"
  StrCpy $UnInstallName "${SETUP_FILENAME}Uninstall"
  
  ; manage install dir with optionnal subdir
  !ifdef SETUP_SUBINSTALLDIR
	StrCpy $SetupInstallDir "$INSTDIR\${SETUP_SUBINSTALLDIR}\${SETUP_FILENAME}"
  !else
	StrCpy $SetupInstallDir "$INSTDIR\${SETUP_FILENAME}"
  !endif
  
SectionEnd

!include "WindowsProgramRegistry.nsh"

Section "Install"
  
  SetOutPath "$SetupInstallDir"
  CreateDirectory $SetupInstallDir
    
  File logo.ico
  
  !ifdef SETUP_COPYFILEPATH & SETUP_COPYFILENAME
	; copy file or dir
    File /a /r ${SETUP_COPYFILEPATH}${SETUP_COPYFILENAME}
  !endif
  
  !ifdef SETUP_COPYDIR
    File /nonfatal /a /r "${SETUP_COPYDIR}\"
  !endif
	
  ;Create uninstaller
  WriteUninstaller "$SetupInstallDir\$UnInstallName.exe"

SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"
  ; current install dir
  RMDir /r "$INSTDIR"
  
  ; manage optionnal subdir
  !ifdef SETUP_SUBINSTALLDIR
	RMDir "$INSTDIR\.."
  !endif
  
  SetRegView 64
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SETUP_GUID}"
  
SectionEnd


