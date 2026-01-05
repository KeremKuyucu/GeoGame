try {
    # 0. Değişkenler ve Yollar
    $projectRoot = "C:\Users\Kerem\Projects\geogame-flutter"
    $webDeployPath = "C:\Users\Kerem\Projects\geogame-web-build"
    $apkOutputPath = "C:\Users\Kerem\Projects\APKs" # APK'ların kopyalanacağı yer
    $innoSetupPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" # ISCC yolu (Kontrol et!)
    $issFilePath = "C:\Users\Kerem\Projects\geogame-flutter\InnoSetup.iss" # .iss dosyanın yolu

    # Klasör yoksa oluştur (APK için)
    if (!(Test-Path $apkOutputPath)) { New-Item -ItemType Directory -Path $apkOutputPath }

    Write-Host "İşlemler başlatılıyor..." -ForegroundColor Cyan

    # 1. Platform Derlemeleri
    Write-Host "`n--- Web Derleniyor ---" -ForegroundColor Gray
    flutter build web --release
    if ($LASTEXITCODE -ne 0) { throw "Web build hatası!" }

    Write-Host "`n--- APK Derleniyor ---" -ForegroundColor Gray
    flutter build apk --release --split-per-abi
    if ($LASTEXITCODE -ne 0) { throw "APK build hatası!" }

    Write-Host "`n--- Windows Derleniyor ---" -ForegroundColor Gray
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) { throw "Windows build hatası!" }

    # 2. APK'ları Kopyala
    Write-Host "`nAPK'lar kopyalanıyor..." -ForegroundColor Green
    Copy-Item -Path ".\build\app\outputs\flutter-apk\*.apk" -Destination $apkOutputPath -Force

    # 3. Inno Setup ile EXE Oluştur
    if (Test-Path $innoSetupPath) {
        Write-Host "`nInno Setup çalıştırılıyor, EXE oluşturuluyor..." -ForegroundColor Magenta
        & $innoSetupPath $issFilePath
        if ($LASTEXITCODE -ne 0) { throw "Inno Setup derleme hatası!" }
    } else {
        Write-Warning "Inno Setup (ISCC.exe) bulunamadı, bu adım atlanıyor."
    }

    # 4. Web Build Aktarımı ve Git Push
    if (Test-Path $webDeployPath) {
        Write-Host "`nWeb dosyaları senkronize ediliyor..." -ForegroundColor Green
        Get-ChildItem -Path $webDeployPath -Exclude .git | Remove-Item -Recurse -Force
        Copy-Item -Path ".\build\web\*" -Destination $webDeployPath -Recurse -Force

        cd $webDeployPath
        git add .
        git commit -m "Auto-build & Deploy: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        git push origin main --force
        
        cd $projectRoot
        Write-Host "`n[BAŞARILI] Web yayınlandı, APK'lar kopyalandı ve EXE oluşturuldu." -ForegroundColor Green
    } else {
        throw "HATA: $webDeployPath bulunamadı!"
    }
}
catch {
    Write-Host "`nBİR HATA OLUŞTU: $_" -ForegroundColor Red
}
finally {
    Write-Host "`nÇıkmak için bir tuşa basın..." -ForegroundColor Yellow
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}