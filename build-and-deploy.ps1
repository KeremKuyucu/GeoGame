#requires -version 5.1
<#
.SYNOPSIS
    GeoGame - Otomatik Build, Imzala ve Dagit (Web / APK / AAB / Windows)
.DESCRIPTION
    Flutter projesini secilen platformlar icin derler, Inno Setup ile installer olusturur,
    signtool ile imzalar, web build'i Vercel CLI ile deploy eder ve opsiyonel GitHub Release yapar.
.NOTES
    Proje kokunde calistirilmalidir. ISS, PFX vb. yollari asagida config bolumunden degistirin.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# -- Renk & Log Yardimcilari -------------------------------------------------------
function Write-Step   ([string]$msg) { Write-Host "`n>> $msg" -ForegroundColor Cyan }
function Write-Info   ([string]$msg) { Write-Host "   [i] $msg" -ForegroundColor DarkGray }
function Write-Ok     ([string]$msg) { Write-Host "   [OK] $msg" -ForegroundColor Green }
function Write-Warn   ([string]$msg) { Write-Host "   [!] $msg" -ForegroundColor Yellow }
function Write-Err    ([string]$msg) { Write-Host "   [X] $msg" -ForegroundColor Red }

# -- Islem Suresi Olcumu -----------------------------------------------------------
function Format-Elapsed ([TimeSpan]$ts) {
    if ($ts.TotalMinutes -ge 1) {
        return "{0:N0}dk {1:N0}sn" -f $ts.TotalMinutes, $ts.Seconds
    }
    return "{0:N1}sn" -f $ts.TotalSeconds
}

try {
    $scriptStopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # -- 0) Yapilandirma -----------------------------------------------------------
    $projectRoot = $PSScriptRoot
    Set-Location $projectRoot

    $projectsParent = Split-Path -Parent $projectRoot
    $outputsRoot   = if (Test-Path (Join-Path $projectsParent "Outputs")) { Join-Path $projectsParent "Outputs" } else { "C:\Users\Kerem\Projects\Outputs" }
    $appName       = "GeoGame"
    $distPath      = $outputsRoot
    $innoSetupPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    $issFilePath   = Join-Path $projectRoot "InnoSetup.iss"
    $innoOutPath   = Join-Path $projectRoot "Output"

    # Vercel CLI
    # `vercel login` ile bir kere giris yapilmis olmalidir.
    # Projeyi ilk kez deploy ediyorsaniz once `vercel link` calistirin.
    $vercelCmd = "vercel"  # PATH'te yoksa tam yolu verin: "C:\...\vercel.cmd"

    # SignTool / PFX
    $signtool           = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x86\signtool.exe"
    $imzaDir            = if (Test-Path (Join-Path $projectsParent "imza-bilgileri")) { Join-Path $projectsParent "imza-bilgileri" } else { "C:\Users\Kerem\Projects\imza-bilgileri" }
    $pfxPath            = Join-Path $imzaDir "KeremKuyucu.pfx"
    $pfxPropertiesPath  = Join-Path $imzaDir "pfx.properties"
    $pfxPassPlain       = $null
    $vercelTokenPath    = Join-Path $imzaDir "geogame.vercel"
    $vercelToken        = $null

    # Google Play Console / API
    $playPackageName   = "com.keremkuyucu.geogame"
    $playUploadScript  = Join-Path $projectRoot "scripts\upload_play_store.py"

    # Inno installer ciktisindaki dosya adi ipucu (OutputBaseFilename ile eslessin)
    $installerNameHint = "GeoGame"
    $timestampServers  = @(
        "http://timestamp.sectigo.com",
        "http://timestamp.digicert.com",
        "http://tsa.starfieldtech.com",
        "http://timestamp.globalsign.com/tsa/r6advanced1"
    )

    # -- Yardimci Fonksiyonlar -----------------------------------------------------
    function Ensure-Dir ([string]$path) {
        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
    }

    function Escape-ProcessArg ([string]$arg) {
        if ($arg -match '\s') {
            return "`"$arg`""
        }
        return $arg
    }

    function Run-Exe {
        <#
        .SYNOPSIS
            Harici prosesi calistirir; stdout/stderr async okunur (deadlock onlenir).
            PowerShell 5.1 (.NET Framework) uyumludur.
        #>
        param(
            [Parameter(Mandatory = $true)][string]$FilePath,
            [Parameter(Mandatory = $false)][string[]]$ArgumentList = @(),
            [Parameter(Mandatory = $false)][string]$WorkingDirectory = $projectRoot,
            [Parameter(Mandatory = $false)][switch]$AllowNonZero
        )

        $resolvedPath = $FilePath
        $prependArgs  = @()
        $cmd = Get-Command $FilePath -ErrorAction SilentlyContinue
        if ($cmd) {
            $resolvedPath = $cmd.Source
            if ($resolvedPath -match '\.(bat|cmd)$') {
                $prependArgs  = @("/c", $resolvedPath)
                $resolvedPath = "$env:SystemRoot\System32\cmd.exe"
            }
        }

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName               = $resolvedPath
        $psi.WorkingDirectory       = $WorkingDirectory
        $psi.UseShellExecute        = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError  = $true
        $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
        $psi.StandardErrorEncoding  = [System.Text.Encoding]::UTF8

        $allArgs = $prependArgs + $ArgumentList
        if ($allArgs.Count -gt 0) {
            $psi.Arguments = ($allArgs | ForEach-Object { Escape-ProcessArg $_ }) -join ' '
        }

        $proc           = New-Object System.Diagnostics.Process
        $proc.StartInfo = $psi

        $stdoutBuilder = New-Object System.Text.StringBuilder
        $stderrBuilder = New-Object System.Text.StringBuilder

        $onStdout = { if ($EventArgs.Data) { [void]$Event.MessageData.AppendLine($EventArgs.Data) } }
        $onStderr = { if ($EventArgs.Data) { [void]$Event.MessageData.AppendLine($EventArgs.Data) } }

        $stdoutEvent = Register-ObjectEvent -InputObject $proc -EventName OutputDataReceived -Action $onStdout -MessageData $stdoutBuilder
        $stderrEvent = Register-ObjectEvent -InputObject $proc -EventName ErrorDataReceived  -Action $onStderr -MessageData $stderrBuilder

        Write-Host "   >> $FilePath $($psi.Arguments)" -ForegroundColor DarkGray

        try {
            [void]$proc.Start()
            $proc.BeginOutputReadLine()
            $proc.BeginErrorReadLine()
            $proc.WaitForExit()

            Start-Sleep -Milliseconds 200

            $stdout = $stdoutBuilder.ToString().TrimEnd()
            $stderr = $stderrBuilder.ToString().TrimEnd()

            if ($stdout) { Write-Host $stdout }
            if ($stderr -and $proc.ExitCode -ne 0) {
                Write-Host $stderr -ForegroundColor Red
            }
            elseif ($stderr) {
                Write-Host $stderr -ForegroundColor DarkYellow
            }

            if ($proc.ExitCode -ne 0 -and -not $AllowNonZero) {
                throw "Komut basarisiz (ExitCode=$($proc.ExitCode)): $FilePath $($psi.Arguments)"
            }
            return $proc.ExitCode
        }
        finally {
            Unregister-Event -SourceIdentifier $stdoutEvent.Name -ErrorAction SilentlyContinue
            Unregister-Event -SourceIdentifier $stderrEvent.Name -ErrorAction SilentlyContinue
            Remove-Job -Id $stdoutEvent.Id -Force -ErrorAction SilentlyContinue
            Remove-Job -Id $stderrEvent.Id -Force -ErrorAction SilentlyContinue
            $proc.Dispose()
        }
    }

    function Invoke-AgyReleaseNotes ([string]$ver) {
        <#
        .SYNOPSIS
            Antigravity CLI (agy) kullanarak git degisikliklerinden surum notlarini otomatik olusturur.
        #>
        $agyCmd = Get-Command "agy" -ErrorAction SilentlyContinue
        if (-not $agyCmd) {
            Write-Warn "Antigravity CLI ('agy') sistemde bulunamadi. Surum notlari otomatik olusturulamadi."
            return $false
        }

        Write-Step "Antigravity CLI (agy) ile Surum Notlari Olusturuluyor (v$ver)..."
        Write-Info "Son commit loglari ve degisiklikler inceleniyor..."

        $agyPrompt = "GeoGame projesinin v$ver surumu icin surum notlarini olustur. " +
            "1. Git commit loglarini ve son degisiklikleri incele. " +
            "2. RELEASE_TEMPLATE.md sablonuna birebir uyarak 'RELEASE_$ver.md' dosyasini olustur. " +
            "3. RELEASE_TEMPLATE_PLAYSTORE.md sablonuna birebir uyarak (her dil icin max 500 karakter, <locale> etiketleri ile) 'RELEASE_PLAY_STORE_$ver.md' dosyasini olustur. " +
            "Dosyalari dogrudan proje kok dizininde olustur."

        try {
            $exitCode = Run-Exe -FilePath "agy" -ArgumentList @(
                "-p", $agyPrompt,
                "--add-dir", $projectRoot,
                "--dangerously-skip-permissions"
            ) -WorkingDirectory $projectRoot -AllowNonZero

            $ghNotes   = Join-Path $projectRoot "RELEASE_$ver.md"
            $playNotes = Join-Path $projectRoot "RELEASE_PLAY_STORE_$ver.md"

            if (Test-Path $ghNotes) {
                Write-Ok "GitHub surum notu hazir: RELEASE_$ver.md"
            }
            if (Test-Path $playNotes) {
                Write-Ok "Play Store surum notu hazir: RELEASE_PLAY_STORE_$ver.md"
            }
            return ($exitCode -eq 0)
        }
        catch {
            Write-Warn "Antigravity CLI calistirilirken hata olustu: $($_.Exception.Message)"
            return $false
        }
    }

    # -- 1) Versiyon Bilgisi -------------------------------------------------------
    $pubspecPath    = Join-Path $projectRoot "pubspec.yaml"
    $currentVersion = $null

    if (Test-Path $pubspecPath) {
        $versionLine = Get-Content $pubspecPath | Select-String "^\s*version:\s*"
        if ($versionLine) {
            $currentVersion = ($versionLine.ToString().Split(":")[1].Trim().Split("+")[0]).Trim()
        }
    }

    if ([string]::IsNullOrWhiteSpace($currentVersion)) {
        Write-Warn "Versiyon bilgisi pubspec.yaml'dan alinamadi."
        $userInput = Read-Host "Lutfen versiyon numarasini girin (Orn: 1.5.3)"
        if ([string]::IsNullOrWhiteSpace($userInput)) {
            throw "HATA: Versiyon girmeden devam edilemez!"
        }
        $currentVersion = $userInput.Trim()
    }

    # Cikti klasorunu uygulamaya ve surume gore yapilandir: Outputs\GeoGame\v1.6.9
    $verFolder = if ($currentVersion -match '^v') { $currentVersion } else { "v$currentVersion" }
    $distPath  = Join-Path (Join-Path $outputsRoot $appName) $verFolder
    Ensure-Dir $distPath

    $verPadded = $currentVersion.PadRight(14)
    Write-Host ""
    Write-Host "+=======================================================+" -ForegroundColor Cyan
    Write-Host "|   GeoGame Build & Deploy  -  Versiyon $verPadded   |" -ForegroundColor Cyan
    Write-Host "+=======================================================+" -ForegroundColor Cyan
    Write-Info "Cikti Dizini: $distPath"

    # -- 2) Platform Secim Menusu --------------------------------------------------
    function Show-PlatformMenu {
        $platforms = @(
            [pscustomobject]@{ Name = "Web"; Command = @("flutter", "build", "web", "--release"); Selected = $true }
            [pscustomobject]@{ Name = "APK"; Command = @("flutter", "build", "apk", "--release", "--split-per-abi"); Selected = $true }
            [pscustomobject]@{ Name = "AAB"; Command = @("flutter", "build", "appbundle", "--release"); Selected = $true }
            [pscustomobject]@{ Name = "Windows"; Command = @("flutter", "build", "windows", "--release"); Selected = $true }
        )

        $currentIndex = 0
        $menuActive   = $true

        Write-Host "`n-- Platform Secimi --" -ForegroundColor Cyan
        Write-Host "   Yukari/Asagi: Gezinme | Space: Sec/Kaldir | Enter: Onayla" -ForegroundColor DarkGray
        Write-Host ""

        $menuTop = [Console]::CursorTop
        for ($i = 0; $i -lt $platforms.Count; $i++) { Write-Host "" }

        while ($menuActive) {
            [Console]::SetCursorPosition(0, $menuTop)

            for ($i = 0; $i -lt $platforms.Count; $i++) {
                if ($i -eq $currentIndex) { $prefix = " > " } else { $prefix = "   " }
                if ($platforms[$i].Selected) { $checkbox = "[X]" } else { $checkbox = "[ ]" }
                if ($i -eq $currentIndex) { $color = "Yellow" } else { $color = "White" }
                $line = "{0}{1} {2}" -f $prefix, $checkbox, $platforms[$i].Name
                Write-Host $line.PadRight(40) -ForegroundColor $color
            }

            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            switch ($key.VirtualKeyCode) {
                38 { if ($currentIndex -gt 0) { $currentIndex-- } }
                40 { if ($currentIndex -lt ($platforms.Count - 1)) { $currentIndex++ } }
                32 { $platforms[$currentIndex].Selected = -not $platforms[$currentIndex].Selected }
                13 { $menuActive = $false }
            }
        }

        Write-Host ""
        return $platforms | Where-Object { $_.Selected }
    }

    $selectedPlatforms = Show-PlatformMenu
    if (-not $selectedPlatforms -or @($selectedPlatforms).Count -eq 0) {
        Write-Warn "Hicbir platform secilmedi. Cikiliyor..."
        return
    }

    $selectedNames = @($selectedPlatforms | ForEach-Object { $_.Name })
    Write-Ok "Secilen platformlar: $($selectedNames -join ', ')"

    # -- 2.1) Sistem & Bagimlilik On-Kontrolleri (Pre-flight Checks) -----------------
    Write-Host ""
    Write-Host "+=======================================================+" -ForegroundColor Cyan
    Write-Host "|    Sistem & On-Ucus Kontrolleri (Pre-flight Checks)   |" -ForegroundColor Cyan
    Write-Host "+=======================================================+" -ForegroundColor Cyan

    # A) Temel Flutter Kontrolu
    $flutterCheck = Get-Command "flutter" -ErrorAction SilentlyContinue
    if (-not $flutterCheck) {
        throw "Flutter SDK sistemde bulunamadi! PATH ortam degiskeninizi kontrol edin."
    }
    Write-Ok "Flutter SDK hazir: $($flutterCheck.Source)"

    # B) Web Kontrolleri (Web secildiyse)
    if ($selectedNames -contains "Web") {
        Write-Step "[Web] Vercel CLI & Proje Tokeni Kontrol Ediliyor"
        $vercelCheck = Get-Command $vercelCmd -ErrorAction SilentlyContinue
        if (-not $vercelCheck) {
            throw "Vercel CLI bulunamadi. Kurmak icin: npm i -g vercel"
        }

        # Token Yukleme: VERCEL_TOKEN env var -> imza-bilgileri\geogame.vercel
        if (-not [string]::IsNullOrWhiteSpace($env:VERCEL_TOKEN)) {
            $vercelToken = $env:VERCEL_TOKEN.Trim()
            Write-Info "Vercel token ortam degiskeninden (VERCEL_TOKEN) alindi."
        }
        elseif (Test-Path $vercelTokenPath) {
            $rawToken = (Get-Content $vercelTokenPath -Raw).Trim()
            if (-not [string]::IsNullOrWhiteSpace($rawToken)) {
                $vercelToken = $rawToken
                $env:VERCEL_TOKEN = $vercelToken
                Write-Info "Vercel token '$vercelTokenPath' dosyasindan okundu."
            }
        }

        # Eger token hala yoksa kullanicidan iste ve imza klasorune kalici kaydet
        if ([string]::IsNullOrWhiteSpace($vercelToken)) {
            Write-Warn "Vercel token bulunamadi."
            $userInputToken = Read-Host "Lutfen Vercel Access Token'inizi yapistirin (imza klasorune kaydedilecek)"
            if (-not [string]::IsNullOrWhiteSpace($userInputToken)) {
                $vercelToken = $userInputToken.Trim()
                $env:VERCEL_TOKEN = $vercelToken
                Ensure-Dir (Split-Path -Parent $vercelTokenPath)
                Set-Content -Path $vercelTokenPath -Value $vercelToken -Force -Encoding UTF8
                Write-Ok "Vercel token '$vercelTokenPath' dosyasina kaydedildi."
            }
        }

        # Token / API Kontrolu
        $tokenValid = $false
        if (-not [string]::IsNullOrWhiteSpace($vercelToken)) {
            Write-Info "Proje tokeni Vercel API uzerinden dogrulaniyor..."
            $httpCode = (curl.exe -s -o NUL -w "%{http_code}" -H "Authorization: Bearer $vercelToken" "https://api.vercel.com/v9/projects/geogame-web-build").Trim()
            if ($httpCode -eq "200") {
                $tokenValid = $true
                Write-Ok "Vercel proje tokeni dogrulandi: geogame-web-build (HTTP 200 OK)"
            } else {
                Write-Warn "Vercel API tokeni reddetti (HTTP $httpCode)."
            }
        }

        # Eger proje tokeni gecersizse veya yoksa kullanici oturumu kontrol et
        if (-not $tokenValid) {
            $whoamiExit = Run-Exe -FilePath "cmd.exe" -ArgumentList @("/c", "$vercelCmd whoami") -AllowNonZero
            if ($whoamiExit -ne 0) {
                Write-Warn "Vercel oturumu dogrulanamadi."
                Write-Step "Vercel Girisi Baslatiliyor (vercel login)..."
                Run-Exe -FilePath "cmd.exe" -ArgumentList @("/c", "$vercelCmd login")
                $whoamiExit = Run-Exe -FilePath "cmd.exe" -ArgumentList @("/c", "$vercelCmd whoami") -AllowNonZero
                if ($whoamiExit -ne 0) {
                    throw "Vercel oturumu dogrulanamadi! Derleme surecleri baslatilmadan islem durduruldu."
                }
            }
            Write-Ok "Vercel kullanici oturumu aktif."
        }
    }

    # C) Windows Kontrolleri (Windows secildiyse)
    if ($selectedNames -contains "Windows") {
        Write-Step "[Windows] Inno Setup, SignTool & Sertifika Kontrol Ediliyor"
        if (-not (Test-Path $innoSetupPath)) {
            throw "Inno Setup Compiler (ISCC.exe) bulunamadi: $innoSetupPath"
        }
        Write-Ok "Inno Setup Compiler (ISCC.exe) hazir."

        if (-not (Test-Path $issFilePath)) {
            throw "Inno Setup script dosyasi bulunamadi: $issFilePath"
        }
        Write-Ok "Inno Setup Scripti ($issFilePath) hazir."

        if (-not (Test-Path $signtool)) {
            throw "SignTool bulunamadi: $signtool"
        }
        Write-Ok "SignTool (signtool.exe) hazir."

        if (-not (Test-Path $pfxPath)) {
            throw "Windows PFX sertifikasi bulunamadi: $pfxPath"
        }
        Write-Ok "PFX sertifikasi hazir ($pfxPath)."

        # PFX sifresi on-kontrolu
        if (Test-Path $pfxPropertiesPath) {
            $propLine = Get-Content $pfxPropertiesPath | Select-String "^\s*password\s*="
            if ($propLine) {
                $pfxPassPlain = ($propLine.ToString().Split("=", 2)[1]).Trim()
                Write-Ok "PFX sifresi pfx.properties dosyasindan okundu."
            }
        }
        if ([string]::IsNullOrWhiteSpace($pfxPassPlain)) {
            Write-Warn "pfx.properties bulunamadi veya password satiri yok."
            $pfxPassSecure = Read-Host "Lutfen PFX sertifika sifresini girin (guvenli)" -AsSecureString
            $bstr          = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pfxPassSecure)
            $pfxPassPlain  = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
            if ([string]::IsNullOrWhiteSpace($pfxPassPlain)) {
                throw "PFX sifresi olmadan Windows installer imzalanamaz!"
            }
            Write-Ok "PFX sifresi alindi."
        }
    }

    # D) Android Kontrolleri (APK veya AAB secildiyse)
    if ($selectedNames -contains "APK" -or $selectedNames -contains "AAB") {
        Write-Step "[Android] Imza (Keystore) Yapilandirmasi Kontrol Ediliyor"
        $keyPropsFile = Join-Path $imzaDir "key.properties"
        if (Test-Path $keyPropsFile) {
            Write-Ok "Android imza yapilandirmasi hazir: $keyPropsFile"
        } else {
            Write-Warn "Android key.properties dosyasi '$imzaDir' altinda bulunamadi."
        }
    }

    # E) Dagitim & Opsiyonel Araclar Kontrolleri
    Write-Step "[Dagitim & Opsiyonel Araclar] Kontrol Ediliyor"

    # Python & Google Play Store upload
    $pythonCmd = Get-Command "python" -ErrorAction SilentlyContinue
    if ($pythonCmd) {
        Write-Ok "Python hazir: $($pythonCmd.Source)"
    } elseif ($selectedNames -contains "AAB") {
        Write-Warn "Python bulunamadi! Google Play Console yuklemesi calismayabilir."
    }

    # Service Account JSON (AAB secildiyse)
    if ($selectedNames -contains "AAB") {
        $saFiles = @(Get-ChildItem -Path $imzaDir -Filter "*.json" -ErrorAction SilentlyContinue)
        if ($saFiles.Count -gt 0) {
            Write-Ok "Play Store Service Account JSON hazir: $($saFiles[0].Name)"
        } else {
            Write-Warn "Service Account JSON dosyasi '$imzaDir' altinda bulunamadi."
        }
    }

    # GitHub CLI
    $ghCmd = Get-Command "gh" -ErrorAction SilentlyContinue
    if ($ghCmd) {
        $ghStatus = (& cmd.exe /c "gh auth status" 2>&1 | Out-String).Trim()
        if ($LASTEXITCODE -eq 0) {
            $ghUserLine = ($ghStatus -split "[\r\n]+" | Where-Object { $_ -match "account" } | Select-Object -First 1)
            $ghUser = if ($ghUserLine) { $ghUserLine.Trim() } else { "Giris yapilmis" }
            Write-Ok "GitHub CLI hazir ($ghUser)."
        } else {
            Write-Warn "GitHub CLI oturumu kapali (Opsiyonel GitHub Release atlanabilir)."
        }
    } else {
        Write-Info "GitHub CLI ('gh') kurulu degil (Opsiyonel GitHub Release atlanabilir)."
    }

    # Antigravity CLI (agy)
    $agyCmd = Get-Command "agy" -ErrorAction SilentlyContinue
    if ($agyCmd) {
        Write-Ok "Antigravity CLI (agy) hazir."
    } else {
        Write-Info "Antigravity CLI ('agy') sistemde bulunamadi (Surum notlari manuel olusturulacak)."
    }

    Write-Host "+=======================================================+" -ForegroundColor Cyan
    Write-Ok "Tum on-kontroller basarili! Derleme hazirligina geciliyor."

    # -- Flutter Clean (Opsiyonel) -------------------------------------------------
    $doClean = Read-Host "`nOnce 'flutter clean' calistirilsin mi? (e/H)"
    if ($doClean -match '^[Ee]$') {
        Write-Step "Flutter Clean"
        Run-Exe -FilePath "flutter" -ArgumentList @("clean") -WorkingDirectory $projectRoot
        Run-Exe -FilePath "flutter" -ArgumentList @("pub", "get") -WorkingDirectory $projectRoot
    }

    # -- 3) Build Surecleri --------------------------------------------------------
    $buildResults = @{}

    foreach ($platform in @($selectedPlatforms)) {
        Write-Step "$($platform.Name) Derleniyor..."
        $sw = [System.Diagnostics.Stopwatch]::StartNew()

        try {
            $cmdParts = $platform.Command
            Run-Exe -FilePath $cmdParts[0] -ArgumentList $cmdParts[1..($cmdParts.Count - 1)] -WorkingDirectory $projectRoot
            $sw.Stop()
            $buildResults[$platform.Name] = [pscustomobject]@{
                Elapsed = $sw.Elapsed
                Success = $true
                Error   = $null
            }
            Write-Ok "$($platform.Name) derlendi - $(Format-Elapsed $sw.Elapsed)"
        }
        catch {
            $sw.Stop()
            $buildResults[$platform.Name] = [pscustomobject]@{
                Elapsed = $sw.Elapsed
                Success = $false
                Error   = $_.Exception.Message
            }
            Write-Err "$($platform.Name) derlemesi basarisiz: $($_.Exception.Message)"
            throw
        }
    }

    # -- 4) APK & AAB Kopyalama ----------------------------------------------------
    if ($selectedNames -contains "APK") {
        Write-Step "APK Dosyalari Kopyalaniyor"

        $flutterApkPath = Join-Path $projectRoot "build\app\outputs\apk\release"
        if (-not (Test-Path $flutterApkPath)) {
            throw "Kaynak APK yolu bulunamadi: $flutterApkPath"
        }

        $apkFiles = @(Get-ChildItem -Path $flutterApkPath -Filter "*.apk" -Recurse)
        if ($apkFiles.Count -eq 0) {
            Write-Warn "APK dosyasi bulunamadi: $flutterApkPath"
        }

        foreach ($apk in $apkFiles) {
            $destFile = Join-Path $distPath $apk.Name
            Copy-Item -Path $apk.FullName -Destination $destFile -Force
            $sizeMB = "{0:N2} MB" -f ($apk.Length / 1MB)
            Write-Info "Kopyalandi: $($apk.Name) ($sizeMB)"
        }
    }

    if ($selectedNames -contains "AAB") {
        Write-Step "AAB (App Bundle) Dosyasi Kopyalaniyor"

        $flutterAabPath = Join-Path $projectRoot "build\app\outputs\bundle\release"
        if (-not (Test-Path $flutterAabPath)) {
            throw "Kaynak AAB yolu bulunamadi: $flutterAabPath"
        }

        $aabFiles = @(Get-ChildItem -Path $flutterAabPath -Filter "*.aab" -Recurse)
        if ($aabFiles.Count -eq 0) {
            Write-Warn "AAB dosyasi bulunamadi: $flutterAabPath"
        }

        foreach ($aab in $aabFiles) {
            $destFile = Join-Path $distPath $aab.Name
            Copy-Item -Path $aab.FullName -Destination $destFile -Force
            $sizeMB = "{0:N2} MB" -f ($aab.Length / 1MB)
            Write-Info "Kopyalandi: $($aab.Name) ($sizeMB)"
        }
    }

    # -- 5) Windows Installer (Inno Setup) + Imzalama -----------------------------
    if ($selectedNames -contains "Windows") {
        if (-not (Test-Path $innoSetupPath)) { throw "Inno Setup bulunamadi: $innoSetupPath" }
        if (-not (Test-Path $issFilePath))   { throw "ISS dosyasi bulunamadi: $issFilePath" }

        Write-Step "Inno Setup Calistiriliyor"
        Run-Exe -FilePath $innoSetupPath -ArgumentList @("/O$distPath", $issFilePath) -WorkingDirectory $projectRoot

        $searchPaths = @()
        if (Test-Path $distPath) { $searchPaths += $distPath }
        if (Test-Path $innoOutPath) { $searchPaths += $innoOutPath }
        if (Test-Path $outputsRoot -and -not ($searchPaths -contains $outputsRoot)) { $searchPaths += $outputsRoot }

        $installerExe = $null

        foreach ($sp in $searchPaths) {
            $installerExe = Get-ChildItem -Path $sp -Filter "*.exe" -File -ErrorAction SilentlyContinue |
                Where-Object { $_.BaseName -like "*$installerNameHint*" } |
                Sort-Object LastWriteTime -Descending |
                Select-Object -First 1
            if ($installerExe) { break }
        }

        if (-not $installerExe) {
            foreach ($sp in $searchPaths) {
                $installerExe = Get-ChildItem -Path $sp -Filter "*.exe" -File -ErrorAction SilentlyContinue |
                    Sort-Object LastWriteTime -Descending |
                    Select-Object -First 1
                if ($installerExe) { break }
            }
        }

        if (-not $installerExe) {
            throw "Installer .exe bulunamadi. Aranan yerler: $($searchPaths -join ', ')"
        }

        $installerDest = Join-Path $distPath $installerExe.Name
        if ($installerExe.FullName -ne $installerDest) {
            Copy-Item $installerExe.FullName $installerDest -Force
            $installerExe = Get-Item $installerDest
        }

        $sizeMB = "{0:N2} MB" -f ($installerExe.Length / 1MB)
        Write-Info "Installer: $($installerExe.Name) ($sizeMB)"

        if (-not (Test-Path $signtool)) { throw "signtool bulunamadi: $signtool" }
        if (-not (Test-Path $pfxPath))  { throw "PFX bulunamadi: $pfxPath" }

        Write-Step "Installer Imzalaniyor"

        $pfxPassPlain = $null
        if (Test-Path $pfxPropertiesPath) {
            $propLine = Get-Content $pfxPropertiesPath | Select-String "^\s*password\s*="
            if ($propLine) {
                $pfxPassPlain = ($propLine.ToString().Split("=", 2)[1]).Trim()
                Write-Info "PFX sifresi pfx.properties dosyasindan okundu."
            }
        }
        if ([string]::IsNullOrWhiteSpace($pfxPassPlain)) {
            Write-Warn "pfx.properties bulunamadi veya password satiri yok."
            $pfxPassSecure = Read-Host "PFX password" -AsSecureString
            $bstr         = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pfxPassSecure)
            $pfxPassPlain  = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }

        try {
            $signedSuccessfully = $false
            foreach ($tsUrl in $timestampServers) {
                Write-Info "Zaman damgasi sunucusu deneniyor: $tsUrl"
                $signExit = Run-Exe -FilePath $signtool -ArgumentList @(
                    "sign", "/fd", "SHA256",
                    "/tr", $tsUrl, "/td", "SHA256",
                    "/f", $pfxPath, "/p", $pfxPassPlain,
                    $installerExe.FullName
                ) -AllowNonZero

                if ($signExit -eq 0) {
                    $signedSuccessfully = $true
                    break
                }
                Write-Warn "$tsUrl sunucusuna erisilemedi veya yanit vermedi, baska sunucu deneniyor..."
            }

            if (-not $signedSuccessfully) {
                Write-Warn "Zaman damgasi sunucularina erisilemedi. Zaman damgasiz imzalaniyor..."
                Run-Exe -FilePath $signtool -ArgumentList @(
                    "sign", "/fd", "SHA256",
                    "/f", $pfxPath, "/p", $pfxPassPlain,
                    $installerExe.FullName
                )
            }

            $verifyExit = Run-Exe -FilePath $signtool -ArgumentList @("verify", "/pa", "/v", $installerExe.FullName) -AllowNonZero
            if ($verifyExit -eq 0) {
                Write-Ok "Installer imzalandi ve dogrulandi."
            } else {
                Write-Warn "Installer imzalandi, ancak dogrulama basarisiz oldu. Bu genellikle sertifikanin Windows tarafindan henuz guvenilir olarak taninmamasindan (self-signed) kaynaklanir."
            }
        }
        finally {
            Remove-Variable -Name pfxPassPlain -Force -ErrorAction SilentlyContinue
        }
    }

    # -- 6) Web Deploy (Vercel CLI) ------------------------------------------------
    if ($selectedNames -contains "Web") {
        $webBuildSrc = Join-Path $projectRoot "build\web"
        if (-not (Test-Path $webBuildSrc)) {
            throw "Web build ciktisi bulunamadi: $webBuildSrc"
        }

        # vercel CLI kurulu mu?
        $vercelCheck = Get-Command $vercelCmd -ErrorAction SilentlyContinue
        if (-not $vercelCheck) {
            throw "Vercel CLI bulunamadi. Kurmak icin: npm i -g vercel"
        }

        # Vercel baglantisini korumak icin yedegi geri yukle (flutter clean sonrasi silinmis olabilir)
        $vercelBackupDir = Join-Path $projectRoot ".vercel_backup"
        $vercelDestDir   = Join-Path $webBuildSrc ".vercel"
        if (Test-Path $vercelBackupDir) {
            Ensure-Dir $vercelDestDir
            Copy-Item -Path (Join-Path $vercelBackupDir "project.json") -Destination (Join-Path $vercelDestDir "project.json") -Force
            Write-Info "Vercel proje baglantisi yedekten geri yuklendi."
        }

        Write-Step "Vercel'e Deploy Ediliyor"
        Write-Info "Kaynak: $webBuildSrc"

        # `vercel --prod` komutu projeyi production ortamina deploy eder.
        # Proje ilk kez deploy ediliyorsa `vercel link` ile baglanti kurulmus olmalidir.
        # `--yes` bayragi interaktif sorulari atlar.
        $tokenDeployArg = if ($vercelToken) { "--token $vercelToken" } else { "" }
        $deployCmdStr = "$vercelCmd --prod --yes $tokenDeployArg".Trim()

        $deployExit = Run-Exe -FilePath "cmd.exe" `
            -ArgumentList @("/c", $deployCmdStr) `
            -WorkingDirectory $webBuildSrc `
            -AllowNonZero

        if ($deployExit -ne 0) {
            Write-Warn "Vercel deploy basarisiz oldu (ExitCode=$deployExit). Oturum / token yenileme deneniyor..."
            $newTok = Read-Host "Lutfen yeni Vercel Access Token girin (veya Bos birakarak tarayicidan login deneyin)"
            if (-not [string]::IsNullOrWhiteSpace($newTok)) {
                $vercelToken = $newTok.Trim()
                $env:VERCEL_TOKEN = $vercelToken
                Ensure-Dir (Split-Path -Parent $vercelTokenPath)
                Set-Content -Path $vercelTokenPath -Value $vercelToken -Force -Encoding UTF8
                $tokenDeployArg = "--token $vercelToken"
            } else {
                & cmd.exe /c "$vercelCmd login"
                $tokenDeployArg = ""
            }
            $deployCmdStr = "$vercelCmd --prod --yes $tokenDeployArg".Trim()
            Write-Step "Vercel Deploy Tekrar Deneniyor..."
            Run-Exe -FilePath "cmd.exe" `
                -ArgumentList @("/c", $deployCmdStr) `
                -WorkingDirectory $webBuildSrc
        }

        # Vercel baglanti yapilandirmasini gelecekteki build'ler icin yedekle
        $buildProjectJson = Join-Path $vercelDestDir "project.json"
        if (Test-Path $buildProjectJson) {
            Ensure-Dir $vercelBackupDir
            Copy-Item -Path $buildProjectJson -Destination (Join-Path $vercelBackupDir "project.json") -Force
        }

        Write-Ok "Web deploy tamamlandi (Vercel production)."
    }

    # -- 7) Surum Notlari (Antigravity CLI) -----------------------------------------
    $ghNotesFile   = Join-Path $projectRoot "RELEASE_$currentVersion.md"
    $playNotesFile = Join-Path $projectRoot "RELEASE_PLAY_STORE_$currentVersion.md"
    $notesMissing  = (-not (Test-Path $ghNotesFile)) -or (-not (Test-Path $playNotesFile))

    Write-Host ""
    Write-Host "-- Surum Notlari (Antigravity CLI) --" -ForegroundColor Cyan
    if ($notesMissing) {
        $genNotes = Read-Host "   Surum notlari eksik. Antigravity CLI (agy) ile otomatik olusturulsun mu? (E/h)"
        if ($genNotes -notmatch '^[Hh]$') {
            [void](Invoke-AgyReleaseNotes -ver $currentVersion)
        }
    }
    else {
        $regenNotes = Read-Host "   Surum notlari mevcut. Antigravity CLI (agy) ile yeniden olusturulsun mu? (e/H)"
        if ($regenNotes -match '^[Ee]$') {
            [void](Invoke-AgyReleaseNotes -ver $currentVersion)
        }
    }

    # -- 8) GitHub Release (Opsiyonel) ---------------------------------------------
    Write-Host ""
    Write-Host "-- GitHub Release --" -ForegroundColor Cyan
    $createRelease = Read-Host "   GitHub Release olusturulsun mu? (e/H)"

    if ($createRelease -match '^[Ee]$') {
        $releaseFiles = @()

        if ($selectedNames -contains "APK") {
            $apks = @(Get-ChildItem -Path $distPath -Filter "*.apk" -ErrorAction SilentlyContinue)
            foreach ($apk in $apks) { $releaseFiles += $apk.FullName }
        }

        # AAB dosyasi (Google Play Store icin) sadece cikti klasorunde ($distPath) saklanir, GitHub Release'e yuklenmez.

        if ($selectedNames -contains "Windows") {
            $exe = Get-ChildItem -Path $distPath -Filter "*.exe" -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending | Select-Object -First 1
            if ($exe) { $releaseFiles += $exe.FullName }
        }

        if ($releaseFiles.Count -eq 0) {
            Write-Warn "Release icin yuklenecek dosya bulunamadi."
        }
        else {
            $tagName      = "v$currentVersion"
            $releaseTitle = "GeoGame v$currentVersion"

            Push-Location $projectRoot
            try {
                $releaseExists = $false
                try {
                    $null = & gh release view $tagName 2>&1
                    if ($LASTEXITCODE -eq 0) { $releaseExists = $true }
                }
                catch { $releaseExists = $false }

                if ($releaseExists) {
                    Write-Step "Mevcut release'e dosyalar yukleniyor: $tagName"
                    foreach ($file in $releaseFiles) {
                        Write-Info "Yukleniyor: $(Split-Path $file -Leaf)"
                        Run-Exe -FilePath "gh" -ArgumentList @("release", "upload", $tagName, $file, "--clobber") -WorkingDirectory $projectRoot
                    }
                    Write-Ok "Dosyalar mevcut release'e yuklendi: $tagName"
                }
                else {
                    Write-Step "Yeni GitHub Release Olusturuluyor"

                    $releaseNotesFile = Join-Path $projectRoot "RELEASE_$currentVersion.md"
                    $ghArgs           = @("release", "create", $tagName, "--title", $releaseTitle)

                    if (Test-Path $releaseNotesFile) {
                        Write-Info "Release notu dosyasi bulundu: RELEASE_$currentVersion.md"
                        $ghArgs += @("--notes-file", $releaseNotesFile)
                    }
                    else {
                        $releaseNotes = Read-Host "   Release notlari (bos birakilabilir)"
                        if ([string]::IsNullOrWhiteSpace($releaseNotes)) {
                            $releaseNotes = "Version $currentVersion - $(Get-Date -Format 'yyyy-MM-dd')"
                        }
                        $ghArgs += @("--notes", $releaseNotes)
                    }

                    foreach ($file in $releaseFiles) { $ghArgs += $file }

                    Run-Exe -FilePath "gh" -ArgumentList $ghArgs -WorkingDirectory $projectRoot
                    Write-Ok "GitHub Release olusturuldu: $tagName"
                }
            }
            catch {
                Write-Err "GitHub Release islemi basarisiz: $($_.Exception.Message)"
            }
            finally {
                Pop-Location
            }
        }
    }

    # -- 9) Google Play Console Deploy (AAB - Opsiyonel) ---------------------------
    if ($selectedNames -contains "AAB") {
        Write-Host ""
        Write-Host "-- Google Play Console (AAB) --" -ForegroundColor Cyan
        $uploadToPlay = Read-Host "   AAB Google Play Console'a yuklensin mi? (e/H)"

        if ($uploadToPlay -match '^[Ee]$') {
            $swPlay = [System.Diagnostics.Stopwatch]::StartNew()
            try {
                # 1. AAB dosyasini bul
                $aabFile = Get-ChildItem -Path $distPath -Filter "*.aab" -ErrorAction SilentlyContinue |
                    Sort-Object LastWriteTime -Descending | Select-Object -First 1

                if (-not $aabFile) {
                    throw "Yuklenecek AAB dosyasi cikti klasorunde bulunamadi: $distPath"
                }

                # 2. Service Account JSON bul
                $serviceAccountFile = $null
                $saCandidates = @(Get-ChildItem -Path $imzaDir -Filter "*.json" -ErrorAction SilentlyContinue)

                if ($saCandidates.Count -eq 1) {
                    $serviceAccountFile = $saCandidates[0].FullName
                    Write-Info "Service Account bulundu: $($saCandidates[0].Name)"
                }
                elseif ($saCandidates.Count -gt 1) {
                    $match = $saCandidates | Where-Object { $_.Name -match "(play|service|account|google|api)" } | Select-Object -First 1
                    if ($match) {
                        $serviceAccountFile = $match.FullName
                        Write-Info "Service Account secildi: $($match.Name)"
                    }
                    else {
                        $serviceAccountFile = $saCandidates[0].FullName
                        Write-Info "Service Account secildi: $($saCandidates[0].Name)"
                    }
                }

                if ([string]::IsNullOrWhiteSpace($serviceAccountFile) -or -not (Test-Path $serviceAccountFile)) {
                    Write-Warn "Service Account JSON dosyasi '$imzaDir' klasorunde bulunamadi."
                    $userInputSa = Read-Host "   Lutfen Service Account JSON tam dosya yolunu girin (veya iptal icin Enter)"
                    if ([string]::IsNullOrWhiteSpace($userInputSa) -or -not (Test-Path $userInputSa.Trim())) {
                        throw "Gecerli bir Service Account JSON dosyasi olmadan Play Store yuklemesi yapilamaz."
                    }
                    $serviceAccountFile = $userInputSa.Trim()
                }

                # 3. Yayin Kanali (Track)
                Write-Host "`n   Yayin Kanali Secin:" -ForegroundColor DarkGray
                Write-Host "     [1] internal   - Dahili Test (Onerilen / Guvenli)" -ForegroundColor DarkGray
                Write-Host "     [2] alpha      - Kapali Test" -ForegroundColor DarkGray
                Write-Host "     [3] beta       - Acik Test" -ForegroundColor DarkGray
                Write-Host "     [4] production - Uretim (Canli)" -ForegroundColor DarkGray
                $trackInput = Read-Host "   Kanal (1-4, Varsayilan: 1)"
                $selectedTrack = switch ($trackInput.Trim()) {
                    "2" { "alpha" }
                    "3" { "beta" }
                    "4" { "production" }
                    default { "internal" }
                }

                # 4. Yayin Durumu (Status)
                Write-Host "`n   Yayin Durumu Secin:" -ForegroundColor DarkGray
                Write-Host "     [1] completed  - Dogrudan yayina al (%100 rollout)" -ForegroundColor DarkGray
                Write-Host "     [2] draft      - Taslak olarak yukle (Play Console'dan incelemek icin)" -ForegroundColor DarkGray
                $statusInput = Read-Host "   Durum (1-2, Varsayilan: 1)"
                $selectedStatus = switch ($statusInput.Trim()) {
                    "2" { "draft" }
                    default { "completed" }
                }

                # 5. Play Store Surum Notu
                $playNotesFile = Join-Path $projectRoot "RELEASE_PLAY_STORE_$currentVersion.md"

                Write-Step "AAB Google Play Console'a Yukleniyor ($selectedTrack / $selectedStatus)..."
                Write-Info "Paket: $playPackageName"
                Write-Info "Dosya: $($aabFile.Name)"
                Write-Info "Kimlik: $(Split-Path $serviceAccountFile -Leaf)"

                $pyArgs = @(
                    $playUploadScript,
                    "--aab", $aabFile.FullName,
                    "--service-account", $serviceAccountFile,
                    "--package-name", $playPackageName,
                    "--track", $selectedTrack,
                    "--status", $selectedStatus
                )

                if (Test-Path $playNotesFile) {
                    $pyArgs += @("--release-notes", $playNotesFile)
                    Write-Info "Surum notlari eklendi: $(Split-Path $playNotesFile -Leaf)"
                }
                else {
                    Write-Warn "Play Store surum notu dosyasi bulunamadi: RELEASE_PLAY_STORE_$currentVersion.md"
                }

                Run-Exe -FilePath "python" -ArgumentList $pyArgs -WorkingDirectory $projectRoot

                $swPlay.Stop()
                $buildResults["PlayStore"] = [pscustomobject]@{
                    Elapsed = $swPlay.Elapsed
                    Success = $true
                    Error   = $null
                }
                Write-Ok "Google Play Console yuklemesi tamamlandi - $(Format-Elapsed $swPlay.Elapsed)"
            }
            catch {
                $swPlay.Stop()
                $buildResults["PlayStore"] = [pscustomobject]@{
                    Elapsed = $swPlay.Elapsed
                    Success = $false
                    Error   = $_.Exception.Message
                }
                Write-Err "Google Play Console yuklemesi basarisiz: $($_.Exception.Message)"
            }
        }
    }

    # -- Ozet ----------------------------------------------------------------------
    $scriptStopwatch.Stop()

    Write-Host ""
    Write-Host "+=======================================================+" -ForegroundColor Green
    Write-Host "|                     BUILD OZETI                       |" -ForegroundColor Green
    Write-Host "+=======================================================+" -ForegroundColor Green

    foreach ($name in $buildResults.Keys) {
        $r       = $buildResults[$name]
        $status  = if ($r.Success) { "Basarili" } else { "HATALI" }
        $sColor  = if ($r.Success) { "Green" }    else { "Red" }
        $elapsed = Format-Elapsed $r.Elapsed
        $line    = "|  {0,-10}  {1,-12}  {2,-18}  |" -f $name, $status, $elapsed
        Write-Host $line -ForegroundColor $sColor
    }

    if (Test-Path $distPath) {
        $distFiles = Get-ChildItem -Path $distPath -File -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 10
        if ($distFiles) {
            Write-Host "+-------------------------------------------------------+" -ForegroundColor Green
            Write-Host "|  Cikti Dosyalari ($distPath)" -ForegroundColor Green
            foreach ($f in $distFiles) {
                $sizeMB = "{0:N2} MB" -f ($f.Length / 1MB)
                $fLine  = "|    {0,-32} {1,10}" -f $f.Name, $sizeMB
                Write-Host $fLine -ForegroundColor White
            }
        }
    }

    Write-Host "+-------------------------------------------------------+" -ForegroundColor Green
    $totalLine = "|  Toplam Sure: {0,-38}|" -f (Format-Elapsed $scriptStopwatch.Elapsed)
    Write-Host $totalLine -ForegroundColor Cyan
    Write-Host "+=======================================================+" -ForegroundColor Green

    Write-Host ""
    Write-Ok "Surum $currentVersion yayina hazir!"
}
catch {
    Write-Host ""
    Write-Host "+=======================================================+" -ForegroundColor Red
    Write-Host "|              KRITIK HATA                              |" -ForegroundColor Red
    Write-Host "+=======================================================+" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Satir: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor DarkGray
    Write-Host "   Dosya: $($_.InvocationInfo.ScriptName)" -ForegroundColor DarkGray

    if ($null -ne $projectRoot -and (Test-Path $projectRoot)) { Set-Location $projectRoot }
}
finally {
    Write-Host "`nCikmak icin bir tusa basin..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}