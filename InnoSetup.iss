[Setup]
AppName=GeoGame
AppVersion=1.3.7
DefaultDirName={userappdata}\GeoGame
DefaultGroupName=GeoGame
OutputDir=C:\Users\Kerem\Projects
OutputBaseFilename=GeoGame_Installer
Compression=lzma
SolidCompression=yes

[Files]
Source: "C:\Users\Kerem\Projects\StudioProjects\geogame\build\windows\x64\runner\Release\geogame.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Kerem\Projects\StudioProjects\geogame\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Kerem\Projects\StudioProjects\geogame\build\windows\x64\runner\Release\flutter_local_notifications_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Kerem\Projects\StudioProjects\geogame\build\windows\x64\runner\Release\just_audio_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Kerem\Projects\StudioProjects\geogame\build\windows\x64\runner\Release\permission_handler_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Kerem\Projects\StudioProjects\geogame\build\windows\x64\runner\Release\share_plus_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Kerem\Projects\StudioProjects\geogame\build\windows\x64\runner\Release\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion

; Data klasörü ve içeriği
Source: "C:\Users\Kerem\Projects\StudioProjects\geogame\build\windows\x64\runner\Release\data\app.so"; DestDir: "{app}\data"; Flags: ignoreversion
Source: "C:\Users\Kerem\Projects\StudioProjects\geogame\build\windows\x64\runner\Release\data\icudtl.dat"; DestDir: "{app}\data"; Flags: ignoreversion

; Flutter Assets klasörü ve içeriği
Source: "C:\Users\Kerem\Projects\StudioProjects\geogame\build\windows\x64\runner\Release\data\flutter_assets\*"; DestDir: "{app}\data\flutter_assets"; Flags: ignoreversion recursesubdirs createallsubdirs

[Tasks]
Name: "desktopicon"; Description: "Masaüstüne kısayol oluştur"; GroupDescription: "Kısayol seçenekleri"; Flags: unchecked
Name: "startmenuicon"; Description: "Başlat menüsüne kısayol oluştur"; GroupDescription: "Kısayol seçenekleri"; Flags: unchecked

[Icons]
Name: "{userdesktop}\GeoGame"; Filename: "{app}\geogame.exe"; IconFilename: "{app}\logo.ico"; WorkingDir: "{app}"; Tasks: desktopicon
Name: "{group}\GeoGame"; Filename: "{app}\geogame.exe"; IconFilename: "{app}\logo.ico"; WorkingDir: "{app}"; Tasks: startmenuicon

[Run]
Filename: "{app}\geogame.exe"; Description: "GeoGame Başlat"; Flags: nowait postinstall skipifsilent
