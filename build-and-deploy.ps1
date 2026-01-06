[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

try {
    # 0. Değişkenler ve Yollar
    $projectRoot = $PSScriptRoot
    $webDeployPath = "C:\Users\Kerem\Projects\geogame-web-build"
    $apkOutputPath = Join-Path $projectRoot "build\dist\apks"
    $innoSetupPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    $issFilePath = Join-Path $projectRoot "InnoSetup.iss"

    # 1. Versiyon Bilgisini Oku (pubspec.yaml)
    if (Test-Path ".\pubspec.yaml") {
        $versionLine = Get-Content ".\pubspec.yaml" | Select-String "^version:\s*"
        if ($versionLine) {
            $currentVersion = $versionLine.ToString().Split(":")[1].Trim().Split("+")[0]
        } else { $currentVersion = "Unknown" }
    } else { $currentVersion = "Unknown" }

    if ($currentVersion -eq "Unknown") {
        Write-Host "`n[!] Versiyon bilgisi otomatik alınamadı." -ForegroundColor Yellow
        $userInput = Read-Host "Lütfen versiyon numarasını girin (Örn: 1.5.3)"
        if ([string]::IsNullOrWhiteSpace($userInput)) { throw "HATA: Versiyon girmeden devam edilemez!" }
        $currentVersion = $userInput.Trim()
    }

    if (!(Test-Path $apkOutputPath)) { New-Item -ItemType Directory -Path $apkOutputPath -Force }

    Write-Host "--- Otomasyon Başlatıldı (Versiyon: $currentVersion) ---" -ForegroundColor Cyan

    # 2. Derleme Süreçleri
    function Build-Platform($name, $command) {
        Write-Host "`n[$name Derleniyor...]" -ForegroundColor Gray
        Invoke-Expression $command
        if ($LASTEXITCODE -ne 0) { throw "$name build hatası!" }
    }

    Build-Platform "Web" "flutter build web --release"
    Build-Platform "APK" "flutter build apk --release --split-per-abi"
    Build-Platform "Windows" "flutter build windows --release"

    # 3. Dosya İşlemleri & APK Kopyalama
    Write-Host "`n[Dosyalar Kopyalanıyor...]" -ForegroundColor Green
    Copy-Item -Path "$projectRoot\build\app\outputs\flutter-apk\*.apk" -Destination $apkOutputPath -Force

    # 4. Inno Setup (Windows Installer)
    if (Test-Path $innoSetupPath) {
        Write-Host "`n[Inno Setup Çalıştırılıyor...]" -ForegroundColor Magenta
        & $innoSetupPath $issFilePath
    }

    # 5. Web Dağıtım ve Git Push
    if (Test-Path $webDeployPath) {
        Push-Location $webDeployPath
        Write-Host "`n[Web Senkronizasyonu & Git Push...]" -ForegroundColor Green
        
        Get-ChildItem -Exclude .git | Remove-Item -Recurse -Force
        Copy-Item -Path "$projectRoot\build\web\*" -Destination . -Recurse -Force

        git add .
        $commitMsg = "Auto-build V$currentVersion - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        git commit -m $commitMsg
        git push origin main --force
        
        Pop-Location
    }

    Write-Host "`n[BAŞARILI] Sürüm $currentVersion yayına hazır." -ForegroundColor Green
}
catch {
    Write-Host "`n[KRİTİK HATA]: $_" -ForegroundColor Red
    if ($null -ne $projectRoot) { Set-Location $projectRoot }
}
finally {
    Write-Host "`nÇıkmak için bir tuşa basın..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}