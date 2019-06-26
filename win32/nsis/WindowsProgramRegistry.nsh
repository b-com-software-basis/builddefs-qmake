Section "-hidden AddProgramRegistry"
  ${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
  
  SetRegView 64
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppGuid" "DisplayIcon" "$SetupInstallDir\logo.ico"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppGuid" "DisplayName" "$AppName"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppGuid" "DisplayVersion" "$AppVersion"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppGuid" "UninstallString" "$SetupInstallDir\$UnInstallName.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppGuid" "Publisher" "$AppManufacturer"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppGuid" "InstallLocation" "$SetupInstallDir"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppGuid" "MajorVersion" 0x00000001
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppGuid" "MinorVersion" 0x00000000
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppGuid" "NoModify" 0x00000001
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppGuid" "NoRepair" 0x00000001
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppGuid" "InstallDate" "$2$1$0"

SectionEnd
