; ===============================
; GeoGame Inno Setup Script
; ===============================

[Setup]
AppName=GeoGame
AppVersion=1.5.0
AppPublisher=Kerem Kuyucu
DefaultDirName={localappdata}\GeoGame
DefaultGroupName=GeoGame
OutputDir=C:\Users\Kerem\Projects
OutputBaseFilename=GeoGame_Installer
Compression=lzma
SolidCompression=yes
DisableDirPage=no
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

; ===============================
; FILES
; ===============================

[Files]
; Uygulama ikonu
Source: "C:\Users\Kerem\Projects\Flutter\geogame\assets\logo.ico"; \
DestDir: "{app}"; Flags: ignoreversion

; Flutter Windows Release çıktısının TAMAMI
Source: "C:\Users\Kerem\Projects\flutter\geogame\build\windows\x64\runner\Release\*"; \
DestDir: "{app}"; \
Flags: recursesubdirs createallsubdirs ignoreversion

; ===============================
; SHORTCUTS
; ===============================

[Tasks]
Name: "desktopicon"; Description: "Masaüstüne kısayol oluştur"; \
GroupDescription: "Kısayol seçenekleri"; Flags: unchecked

Name: "startmenuicon"; Description: "Başlat menüsüne kısayol oluştur"; \
GroupDescription: "Kısayol seçenekleri"; Flags: unchecked

[Icons]
Name: "{userdesktop}\GeoGame"; \
Filename: "{app}\geogame.exe"; \
IconFilename: "{app}\logo.ico"; \
WorkingDir: "{app}"; \
Tasks: desktopicon

Name: "{group}\GeoGame"; \
Filename: "{app}\geogame.exe"; \
IconFilename: "{app}\logo.ico"; \
WorkingDir: "{app}"; \
Tasks: startmenuicon

; ===============================
; RUN AFTER INSTALL
; ===============================

[Run]
Filename: "{app}\geogame.exe"; \
Description: "GeoGame'i Başlat"; \
Flags: nowait postinstall skipifsilent
