[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

try {
    # 0. Degiskenler ve Yollar
    $projectRoot = $PSScriptRoot
    $webDeployPath = "C:\Users\Kerem\Projects\geogame-web-build"
    # APK cikis klasoru (Dagitim icin kullanilacak olan)
    $distApkPath = "C:\Users\Kerem\Projects\Outputs"
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
        Write-Host "`n[!] Versiyon bilgisi otomatik alinamadi." -ForegroundColor Yellow
        $userInput = Read-Host "Lutfen versiyon numarasini girin (Orn: 1.5.3)"
        if ([string]::IsNullOrWhiteSpace($userInput)) { throw "HATA: Versiyon girmeden devam edilemez!" }
        $currentVersion = $userInput.Trim()
    }

    # Dagitim klasoru yoksa olustur
    if (!(Test-Path $distApkPath)) { New-Item -ItemType Directory -Path $distApkPath -Force }

    Write-Host "--- Otomasyon Baslatildi (Versiyon: $currentVersion) ---" -ForegroundColor Cyan

    # Platform Secim Menusu
    function Show-PlatformMenu {
        $platforms = @(
            @{ Name = "Web"; Command = "flutter build web --release"; Selected = $true },
            @{ Name = "APK"; Command = "flutter build apk --release --split-per-abi"; Selected = $true },
            @{ Name = "Windows"; Command = "flutter build windows --release"; Selected = $true }
        )
        
        $currentIndex = 0
        $menuActive = $true
        
        Write-Host "`n--- Platform Secimi ---" -ForegroundColor Cyan
        Write-Host "Yukari/Asagi: Gezinme | Space: Sec/Kaldir | Enter: Onayla" -ForegroundColor DarkGray
        Write-Host ""
        
        # Ilk cizim icin bos satirlar olustur
        for ($i = 0; $i -lt $platforms.Count; $i++) {
            Write-Host ""
        }
        
        while ($menuActive) {
            # Cursor'u menu basina geri al
            [Console]::SetCursorPosition(0, [Console]::CursorTop - $platforms.Count)
            
            for ($i = 0; $i -lt $platforms.Count; $i++) {
                $prefix = if ($i -eq $currentIndex) { " > " } else { "   " }
                $checkbox = if ($platforms[$i].Selected) { "[X]" } else { "[ ]" }
                $color = if ($i -eq $currentIndex) { "Yellow" } else { "White" }
                
                # Satiri temizle ve yeniden yaz
                Write-Host "$prefix$checkbox $($platforms[$i].Name)".PadRight(30) -ForegroundColor $color
            }
            
            # Tus okuma
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            
            switch ($key.VirtualKeyCode) {
                38 { # Yukari ok
                    if ($currentIndex -gt 0) { $currentIndex-- }
                }
                40 { # Asagi ok
                    if ($currentIndex -lt ($platforms.Count - 1)) { $currentIndex++ }
                }
                32 { # Space
                    $platforms[$currentIndex].Selected = -not $platforms[$currentIndex].Selected
                }
                13 { # Enter
                    $menuActive = $false
                }
            }
        }
        
        Write-Host ""
        return $platforms | Where-Object { $_.Selected }
    }
    
    $selectedPlatforms = Show-PlatformMenu
    
    if ($selectedPlatforms.Count -eq 0) {
        Write-Host "`n[!] Hicbir platform secilmedi. Cikiliyor..." -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nSecilen platformlar: $($selectedPlatforms.Name -join ', ')" -ForegroundColor Green

    # 2. Derleme Surecleri
    function Build-Platform($name, $command) {
        Write-Host "`n[$name Derleniyor...]" -ForegroundColor Gray
        Invoke-Expression $command
        if ($LASTEXITCODE -ne 0) { throw "$name build hatasi!" }
    }

    # Secilen platformlari derle
    foreach ($platform in $selectedPlatforms) {
        Build-Platform $platform.Name $platform.Command
    }

    # Secilen platform isimlerini al
    $selectedNames = $selectedPlatforms | ForEach-Object { $_.Name }

    # 3. Dosya Islemleri & APK Kopyalama (Sadece APK seciliyse)
    if ($selectedNames -contains "APK") {
        Write-Host "`n[APK Dosyalari Kopyalaniyor...]" -ForegroundColor Green
        
        # Flutter'in APK'lari urettigi gercek yol:
        $flutterApkPath = "$projectRoot\build\app\outputs\apk\release"
        
        if (Test-Path $flutterApkPath) {
            # Sadece APK dosyalarini al ve hedef klasore tasi
            Get-ChildItem -Path $flutterApkPath -Filter "*.apk" -Recurse | ForEach-Object {
                $destFile = Join-Path $distApkPath $_.Name
                Copy-Item -Path $_.FullName -Destination $destFile -Force
                Write-Host "Kopyalandi: $($_.Name)" -ForegroundColor Gray
            }
        } else {
            Write-Host "[!] Kaynak APK yolu bulunamadi: $flutterApkPath" -ForegroundColor Red
        }
    }

    # 4. Inno Setup (Windows Installer - Sadece Windows seciliyse)
    if ($selectedNames -contains "Windows") {
        if (Test-Path $innoSetupPath) {
            Write-Host "`n[Inno Setup Calistiriliyor...]" -ForegroundColor Magenta
            & $innoSetupPath $issFilePath
        }
    }

    # 5. Web Dagitim ve Git Push (Sadece Web seciliyse)
    if ($selectedNames -contains "Web") {
        if (Test-Path $webDeployPath) {
            Push-Location $webDeployPath
            Write-Host "`n[Web Senkronizasyonu & Git Push...]" -ForegroundColor Green
            
            # Mevcut dosyalari temizle (.git haric)
            Get-ChildItem -Exclude .git | Remove-Item -Recurse -Force
            
            # Yeni build'i kopyala
            Copy-Item -Path "$projectRoot\build\web\*" -Destination . -Recurse -Force

            git add .
            $commitMsg = "Auto-build V$currentVersion - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
            git commit -m $commitMsg
            git push origin main --force
            
            Pop-Location
        }
    }

    # 6. GitHub Release Olusturma (Opsiyonel)
    Write-Host "`n--- GitHub Release ---" -ForegroundColor Cyan
    $createRelease = Read-Host "GitHub Release olusturulsun mu? (E/H)"
    
    if ($createRelease -eq "E" -or $createRelease -eq "e") {
        # Release dosyalarini hazirla
        $releaseFiles = @()
        
        # APK dosyalari
        if ($selectedNames -contains "APK") {
            $apkFiles = Get-ChildItem -Path $distApkPath -Filter "*.apk" -ErrorAction SilentlyContinue
            foreach ($apk in $apkFiles) {
                $releaseFiles += $apk.FullName
            }
        }
        
        # Windows Installer
        if ($selectedNames -contains "Windows") {
            $installerPath = $distApkPath
            $exeFiles = Get-ChildItem -Path $installerPath -Filter "*.exe" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            if ($exeFiles) {
                $releaseFiles += $exeFiles.FullName
            }
        }
        
        $tagName = "v$currentVersion"
        $releaseTitle = "GeoGame v$currentVersion"
        
        Push-Location $projectRoot
        
        try {
            # Release var mi kontrol et
            $releaseExists = $false
            try {
                $null = gh release view $tagName 2>&1
                $releaseExists = ($LASTEXITCODE -eq 0)
            } catch {
                $releaseExists = $false
            }
            
            if ($releaseExists) {
                # Release zaten var, sadece dosyalari yukle
                Write-Host "`n[Mevcut release'e dosyalar yukleniyor: $tagName]" -ForegroundColor Yellow
                
                foreach ($file in $releaseFiles) {
                    $fileName = Split-Path $file -Leaf
                    Write-Host "  Yukleniyor: $fileName" -ForegroundColor Gray
                    gh release upload $tagName $file --clobber
                }
                
                Write-Host "[OK] Dosyalar mevcut release'e yuklendi: $tagName" -ForegroundColor Green
            }
            else {
                # Yeni release olustur
                Write-Host "`n[Yeni GitHub Release Olusturuluyor...]" -ForegroundColor Magenta
                
                # Release notlari
                $releaseNotes = Read-Host "Release notlari (bos birakilabilir)"
                if ([string]::IsNullOrWhiteSpace($releaseNotes)) {
                    $releaseNotes = "Version $currentVersion - $(Get-Date -Format 'yyyy-MM-dd')"
                }
                
                $ghCommand = "gh release create `"$tagName`" --title `"$releaseTitle`" --notes `"$releaseNotes`""
                
                # Dosyalari ekle
                foreach ($file in $releaseFiles) {
                    $ghCommand += " `"$file`""
                }
                
                Invoke-Expression $ghCommand
                
                Write-Host "[OK] GitHub Release olusturuldu: $tagName" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "[!] GitHub Release islemi basarisiz: $_" -ForegroundColor Red
        }
        
        Pop-Location
    }

    Write-Host "`n[BASARILI] Surum $currentVersion yayina hazir." -ForegroundColor Green
}
catch {
    Write-Host "`n[KRITIK HATA]: $_" -ForegroundColor Red
    if ($null -ne $projectRoot) { Set-Location $projectRoot }
}
finally {
    Write-Host "`nCikmak icin bir tusa basin..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}