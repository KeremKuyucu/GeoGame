; ===============================
; GeoGame Inno Setup Script
; ===============================

[Setup]
AppName=GeoGame
AppVersion=1.6.4
AppPublisher=Kerem Kuyucu

PrivilegesRequired=lowest

DefaultDirName={localappdata}\GeoGame
DefaultGroupName=GeoGame

OutputDir=C:\Users\Kerem\Projects\Outputs
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
Source: "C:\Users\Kerem\Projects\geogame-flutter\assets\images\logo.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Kerem\Projects\geogame-flutter\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

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
Root: HKCU; Subkey: "Software\Classes\io.supabase.geogame"; ValueType: string; ValueName: ""; ValueData: "URL:GeoGame Protocol"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\io.supabase.geogame"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""
Root: HKCU; Subkey: "Software\Classes\io.supabase.geogame\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\geogame.exe,0"
Root: HKCU; Subkey: "Software\Classes\io.supabase.geogame\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\geogame.exe"" ""%1"""
