; helps to manage env var
; http://nsis.sourceforge.net/Path_Manipulation
!include /*@CUSTOM_NSIS_INCLUDE@*/"EnvVarUpdate.nsh"
; helps to manage powershell command
!include /*@CUSTOM_NSIS_INCLUDE@*/"psexec.nsh"

!include /*@CUSTOM_NSIS_INCLUDE@*/"GetTime.nsh"

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
  Var "AppManufacturer"

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  !define MUI_ICON "${SETUP_ICO_FILE}"
  !define MUI_UNICON "${SETUP_ICO_FILE}"

;--------------------------------
;Pages
  !insertmacro MUI_PAGE_DIRECTORY
  
!ifdef CUSTOMIZE_DISPLAY_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_COMPONENTS
!endif
  
  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"

Function .onInit
!ifdef CUSTOMIZE_ONINIT
  Call CustomizeOnInit
!endif
 
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
  ExecWait '$R0 /S' ;Do not copy the uninstaller to a temp file
 
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

Section "-hidden PreInstall"
  SetOutPath "$INSTDIR"
  StrCpy $AppName "${SETUP_PRODUCTNAME}"
  StrCpy $AppGuid "${SETUP_GUID}"
  StrCpy $AppVersion "${SETUP_VERSION}"
  StrCpy $UnInstallName "${SETUP_FILENAME}Uninstall"
  StrCpy $AppManufacturer "${SETUP_MANUFACTURER}"
  
  ; manage install dir with optionnal subdir
  !ifdef SETUP_SUBINSTALLDIR
	StrCpy $SetupInstallDir "$INSTDIR\${SETUP_SUBINSTALLDIR}\${SETUP_FILENAME}"
  !else
	StrCpy $SetupInstallDir "$INSTDIR\${SETUP_FILENAME}"
  !endif
  
SectionEnd

!include /*@CUSTOM_NSIS_INCLUDE@*/"WindowsProgramRegistry.nsh"

Section "-hidden Install"
  SetOutPath "$SetupInstallDir"
  CreateDirectory $SetupInstallDir
    
  File "${SETUP_ICO_FILE}"
  
  !ifdef SETUP_COPYFILEPATH & SETUP_COPYFILENAME
	; copy file or dir
    File /a /r ${SETUP_COPYFILEPATH}${SETUP_COPYFILENAME}
  !endif
  
  !ifdef SETUP_COPYDIR
    File /nonfatal /a /r "${SETUP_COPYDIR}\"
  !endif
	
  ;Create uninstaller
  WriteUninstaller "$SetupInstallDir\$UnInstallName.exe"

  
!ifdef CUSTOMIZE_ADDTOPATH
  ${EnvVarUpdate} $0 "PATH" "A" "HKCU" "$SetupInstallDir"
!endif
SectionEnd

;--------------------------------
; Custom section and function (next line replace)
;@CUSTOM_NSIS_SCRIPT@
;--------------------------------

Section "Uninstall"
  ; current install dir
  RMDir /r "$INSTDIR"
  
  ; manage optionnal subdir
  !ifdef SETUP_SUBINSTALLDIR
	RMDir "$INSTDIR\.."
  !endif
  
  SetRegView 64
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SETUP_GUID}"
  
!ifdef CUSTOMIZE_ADDTOPATH
  ${un.EnvVarUpdate} $0 "PATH" "R" "HKCU" "$SetupInstallDir"
!endif
SectionEnd


