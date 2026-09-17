#requires -version 5.1
<#
.SYNOPSIS
    GeoGame - Otomatik Ekran Goruntusu Yakalayici (Screenshots Tool)
.DESCRIPTION
    Calisan Android emulatoru veya bagli cihazdan Play Store & README icin
    yuksek cozunurluklu ekran goruntulerini tek tusla 'screenshots/' klasorune kaydeder.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

function Write-Header ([string]$text) {
    Write-Host ""
    Write-Host "+=======================================================+" -ForegroundColor Cyan
    Write-Host "|  $($text.PadRight(51))|" -ForegroundColor Cyan
    Write-Host "+=======================================================+" -ForegroundColor Cyan
}

function Write-Ok   ([string]$msg) { Write-Host "   [OK] $msg" -ForegroundColor Green }
function Write-Warn ([string]$msg) { Write-Host "   [!] $msg" -ForegroundColor Yellow }
function Write-Info ([string]$msg) { Write-Host "   [i] $msg" -ForegroundColor DarkGray }

$projectRoot = Split-Path -Parent $PSScriptRoot
$screenshotsDir = Join-Path $projectRoot "screenshots"

if (-not (Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Path $screenshotsDir -Force | Out-Null
}

# ADB Kontrolu
$adbCmd = Get-Command "adb" -ErrorAction SilentlyContinue
if (-not $adbCmd) {
    Write-Warn "ADB komutu bulunamadi. Android SDK platform-tools PATH'te olmalidir."
    Read-Host "`nCikmak icin Enter'a basin..."
    exit 1
}

function Get-ConnectedDevice {
    $devices = @(adb devices | Select-String -Pattern "\b(device)\b" | Where-Object { $_ -notmatch "List of" })
    if ($devices.Count -gt 0) {
        return ($devices[0].ToString().Split("`t")[0]).Trim()
    }
    return $null
}

$device = Get-ConnectedDevice
if (-not $device) {
    Write-Header "Cihaz / Emulator Aranıyor"
    Write-Warn "Bagli bir Android cihazi veya calisan emulator bulunamadi."
    Write-Info "Emulatore baglanmayi dener misiniz? (Pixel_API_34 baslatilabilir)"
    $launch = Read-Host "   Pixel_API_34 emulatorunu baslatmak ister misiniz? (E/h)"
    if ($launch -notmatch '^[Hh]$') {
        Write-Info "Emulator baslatiliyor..."
        Start-Process "flutter" -ArgumentList "emulators", "--launch", "Pixel_API_34"
        Write-Info "Emulatorun acilmasi bekleniyor (15 sn)..."
        Start-Sleep -Seconds 15
        $device = Get-ConnectedDevice
    }
}

if (-not $device) {
    $device = Get-ConnectedDevice
}

if (-not $device) {
    Write-Warn "Cihaz bulunamadi. Lutfen emulatore veya telefona baglanip tekrar calistirin."
    Read-Host "`nCikmak icin Enter'a basin..."
    exit 1
}

function Save-ScreenCapture ([string]$fileName, [string]$label) {
    $destPath = Join-Path $screenshotsDir $fileName
    Write-Info "[$label] cekiliyor..."

    try {
        # adb exec-out screencap -p dogrudan binary PNG uretir
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = "adb"
        $pinfo.Arguments = "exec-out screencap -p"
        $pinfo.UseShellExecute = $false
        $pinfo.RedirectStandardOutput = $true
        
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $pinfo
        $process.Start() | Out-Null
        
        $fileStream = [System.IO.File]::Create($destPath)
        $process.StandardOutput.BaseStream.CopyTo($fileStream)
        $fileStream.Close()
        $process.WaitForExit()
        
        if (Test-Path $destPath) {
            $len = (Get-Item $destPath).Length
            if ($len -gt 1000) {
                $sizeKB = [math]::Round($len / 1KB)
                Write-Ok "Kaydedildi: screenshots/$fileName ($sizeKB KB)"
                return $true
            }
        }
        Write-Warn "Ekran goruntusu alinamadi veya dosya boyutu cok kucuk."
        return $false
    }
    catch {
        Write-Warn "Hata: $($_.Exception.Message)"
        return $false
    }
}

$screenItems = @(
    [pscustomobject]@{ Key = "1"; Name = "mainlobi.png"; Label = "Ana Menü / Lobi" }
    [pscustomobject]@{ Key = "2"; Name = "coatofarms_game.png"; Label = "Arma Avı (Coat of Arms)" }
    [pscustomobject]@{ Key = "3"; Name = "flag_game.png"; Label = "Bayrak Avı (Flag Quiz)" }
    [pscustomobject]@{ Key = "4"; Name = "capital_game.png"; Label = "Başkent Avı (Capital Quiz)" }
    [pscustomobject]@{ Key = "5"; Name = "distance_game.png"; Label = "Mesafe Avı (Distance Game)" }
    [pscustomobject]@{ Key = "6"; Name = "borderpath_game.png"; Label = "Sınır Yolu (Border Path)" }
    [pscustomobject]@{ Key = "7"; Name = "borderline_game.png"; Label = "Sınır Hattı (Borderline)" }
    [pscustomobject]@{ Key = "8"; Name = "findmap_game.png"; Label = "Haritada Bul (Find Map)" }
    [pscustomobject]@{ Key = "9"; Name = "leaderboard.png"; Label = "Liderlik Tablosu (Leaderboard)" }
    [pscustomobject]@{ Key = "10"; Name = "profile.png"; Label = "Profil & İstatistikler" }
)

while ($true) {
    Write-Header "GeoGame Ekran Goruntusu Araci"
    Write-Ok "Aktif Cihaz: $device"
    Write-Info "Kayit Dizini: $screenshotsDir"
    Write-Host ""

    foreach ($item in $screenItems) {
        $keyStr = "[{0}]" -f $item.Key
        Write-Host "   $($keyStr.PadRight(5)) $($item.Label.PadRight(32)) -> $($item.Name)" -ForegroundColor Cyan
    }
    Write-Host "   [A]   TUMUNU SIRAYLA CEK (Rehberli Adim Adim)" -ForegroundColor Yellow
    Write-Host "   [F]   TAM OTOMATIK FLUTTER DRIVE (Test ile Otopilot)" -ForegroundColor Green
    Write-Host "   [C]   Ozel Isimle Cek" -ForegroundColor DarkGray
    Write-Host "   [Q]   Cikis" -ForegroundColor Red
    Write-Host ""

    $secim = (Read-Host "Seciminiz").Trim()

    if ($secim -match '^[Qq]$') {
        break
    }
    elseif ($secim -match '^[Ff]$') {
        Write-Header "Otomatik Flutter Drive Testi Baslatiliyor"
        Write-Info "Komut: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_screenshots_test.dart -d $device"
        & flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_screenshots_test.dart -d $device
        Write-Ok "Flutter Drive tamamlandi. Screenshots klasorunu kontrol edebilirsiniz."
        Start-Sleep -Seconds 2
    }
    elseif ($secim -match '^[Aa]$') {
        Write-Header "Adim Adim Tum Ekranlari Cekme Modu"
        Write-Info "Emulatore gecin, ilgili sayfayi acin ve Enter'a basin.`n"

        for ($i = 0; $i -lt $screenItems.Count; $i++) {
            $item = $screenItems[$i]
            Write-Host ">> ($($i+1)/$($screenItems.Count)) Lutfen '$($item.Label)' ekranini acin." -ForegroundColor Yellow
            $null = Read-Host "   Hazir oldugunuzda Enter'a basin (Atlamak icin 's' yazin)"
            if ($null -notmatch '^[Ss]$') {
                Save-ScreenCapture -fileName $item.Name -label $item.Label
            } else {
                Write-Info "Atlandi."
            }
            Write-Host ""
        }
        Write-Ok "Tum ekranlar tamamlandi!"
        Start-Sleep -Seconds 2
    }
    elseif ($secim -match '^[Cc]$') {
        $customName = Read-Host "Dosya adi (Orn: settings.png)"
        if (-not $customName.EndsWith(".png")) { $customName += ".png" }
        Save-ScreenCapture -fileName $customName -label "Ozel Ekran"
        Start-Sleep -Seconds 1
    }
    else {
        $match = $screenItems | Where-Object { $_.Key -eq $secim }
        if ($match) {
            Save-ScreenCapture -fileName $match.Name -label $match.Label
            Start-Sleep -Seconds 1
        } else {
            Write-Warn "Gecersiz secim!"
            Start-Sleep -Milliseconds 600
        }
    }
}

Write-Ok "Screenshots klasoru: $screenshotsDir"
