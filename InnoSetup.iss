; ===============================
; GeoGame Inno Setup Script
; ===============================
;
; Preprocessor defines (can be overridden via command-line /D flags for CI):
;   ProjectRoot  – absolute path to the Flutter project root
;   OutputDir    – directory where the installer .exe will be written
;   AppVersion   – version string (e.g. 1.6.14)
;
; Local defaults (used when no /D flag is passed):
#ifndef ProjectRoot
  #define ProjectRoot "C:\Users\Kerem\Projects\geogame-flutter"
#endif
#ifndef OutputDir
  #define OutputDir "C:\Users\Kerem\Projects\Outputs"
#endif
#ifndef AppVersion
  #define AppVersion "1.6.15"
#endif

[Setup]
AppName=GeoGame
AppVersion={#AppVersion}
AppPublisher=Kerem Kuyucu

PrivilegesRequired=lowest

DefaultDirName={localappdata}\GeoGame
DefaultGroupName=GeoGame

OutputDir={#OutputDir}
OutputBaseFilename=GeoGame_Installer
Compression=lzma
SolidCompression=yes
DisableDirPage=no

ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; ===============================
; FILES
; ===============================

[Files]
Source: "{#ProjectRoot}\assets\images\logo.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectRoot}\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

; ===============================
; SHORTCUTS
; ===============================

[Tasks]
Name: "desktopicon"; Description: "Masaüstüne kısayol oluştur"; GroupDescription: "Kısayol seçenekleri"; Flags: unchecked
Name: "startmenuicon"; Description: "Başlat menüsüne kısayol oluştur"; GroupDescription: "Kısayol seçenekleri"; Flags: unchecked

[Icons]
Name: "{userdesktop}\GeoGame"; Filename: "{app}\geogame.exe"; IconFilename: "{app}\logo.ico"; WorkingDir: "{app}"; Tasks: desktopicon
Name: "{group}\GeoGame"; Filename: "{app}\geogame.exe"; IconFilename: "{app}\logo.ico"; WorkingDir: "{app}"; Tasks: startmenuicon

; ===============================
; RUN AFTER INSTALL
; ===============================

[Run]
Filename: "{app}\geogame.exe"; Description: "GeoGame'i Başlat"; Flags: nowait postinstall skipifsilent

; ===============================
; URL PROTOCOL (OAUTH DEEP LINK)
; ===============================

[Registry]
Root: HKCU; Subkey: "Software\Classes\com.keremkuyucu.geogame"; ValueType: string; ValueName: ""; ValueData: "URL:GeoGame Protocol"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\com.keremkuyucu.geogame"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""
Root: HKCU; Subkey: "Software\Classes\com.keremkuyucu.geogame\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\geogame.exe,0"
Root: HKCU; Subkey: "Software\Classes\com.keremkuyucu.geogame\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\geogame.exe"" ""%1"""
