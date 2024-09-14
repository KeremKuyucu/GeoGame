@echo off

flutter build apk
flutter build windows
flutter build web

xcopy /Y /I "build\app\outputs\apk\release\app-release.apk" "C:\Users\KeremK\Desktop\app-release.apk"
xcopy /E /I "build\windows\x64\runner\Release" "C:\Users\KeremK\Desktop\Release"
xcopy /E /I "build\web" "C:\Users\KeremK\Desktop\Web"

echo Build ve kopyalama işlemleri tamamlandı.
pause