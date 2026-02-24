#requires -version 5.1
<#
.SYNOPSIS
    GeoGame - Otomatik Build, Imzala ve Dagit (Web / APK / Windows)
.DESCRIPTION
    Flutter projesini secilen platformlar icin derler, Inno Setup ile installer olusturur,
    signtool ile imzalar, web build'i deploy eder ve opsiyonel GitHub Release yapar.
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

    $webDeployPath = "C:\Users\Kerem\Projects\geogame-web-build"
    $distPath = "C:\Users\Kerem\Projects\Outputs"
    $innoSetupPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    $issFilePath = Join-Path $projectRoot "InnoSetup.iss"
    $innoOutPath = Join-Path $projectRoot "Output"

    # SignTool / PFX
    $signtool = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x86\signtool.exe"
    $pfxPath = "C:\Users\Kerem\Projects\Thinks\KeremKuyucu.pfx"
    $pfxPropertiesPath = "C:\Users\Kerem\Projects\Thinks\pfx.properties"

    # Inno installer ciktisindaki dosya adi ipucu (OutputBaseFilename ile eslessin)
    $installerNameHint = "GeoGame"
    $timestampUrl = "http://timestamp.digicert.com"

    # -- Yardimci Fonksiyonlar -----------------------------------------------------
    function Ensure-Dir ([string]$path) {
        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
    }

    function Escape-ProcessArg ([string]$arg) {
        # Bosluk veya ozel karakter iceren argumanlari tirnak icine al
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
            [Parameter(Mandatory = $false)][switch]$AllowNonZero   # Bazi komutlar (git commit) 1 donebilir
        )

        # flutter, git, gh gibi komutlar Windows'ta .bat/.cmd dosyasidir.
        # UseShellExecute=false ile Process.Start bunlari PATH'ten bulamaz.
        # Get-Command ile tam yolu cozumle; .bat/.cmd ise cmd.exe /c uzerinden calistir.
        $resolvedPath = $FilePath
        $prependArgs = @()
        $cmd = Get-Command $FilePath -ErrorAction SilentlyContinue
        if ($cmd) {
            $resolvedPath = $cmd.Source
            # .bat / .cmd dosyalarini cmd.exe uzerinden calistir
            if ($resolvedPath -match '\.(bat|cmd)$') {
                $prependArgs = @("/c", $resolvedPath)
                $resolvedPath = "$env:SystemRoot\System32\cmd.exe"
            }
        }

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $resolvedPath
        $psi.WorkingDirectory = $WorkingDirectory
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
        $psi.StandardErrorEncoding = [System.Text.Encoding]::UTF8

        # PS 5.1 (.NET Framework) ArgumentList desteklemez; Arguments string olarak birlestir
        $allArgs = $prependArgs + $ArgumentList
        if ($allArgs.Count -gt 0) {
            $psi.Arguments = ($allArgs | ForEach-Object { Escape-ProcessArg $_ }) -join ' '
        }

        $proc = New-Object System.Diagnostics.Process
        $proc.StartInfo = $psi

        # Async cikti toplama (buyuk buffer'larda deadlock onlenir)
        $stdoutBuilder = New-Object System.Text.StringBuilder
        $stderrBuilder = New-Object System.Text.StringBuilder

        $onStdout = {
            if ($EventArgs.Data) {
                [void]$Event.MessageData.AppendLine($EventArgs.Data)
            }
        }
        $onStderr = {
            if ($EventArgs.Data) {
                [void]$Event.MessageData.AppendLine($EventArgs.Data)
            }
        }

        $stdoutEvent = Register-ObjectEvent -InputObject $proc -EventName OutputDataReceived -Action $onStdout -MessageData $stdoutBuilder
        $stderrEvent = Register-ObjectEvent -InputObject $proc -EventName ErrorDataReceived  -Action $onStderr -MessageData $stderrBuilder

        Write-Host "   >> $FilePath $($psi.Arguments)" -ForegroundColor DarkGray

        try {
            [void]$proc.Start()
            $proc.BeginOutputReadLine()
            $proc.BeginErrorReadLine()
            $proc.WaitForExit()

            # Olay kuyrugunun bosalmasini bekle
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

    # -- 1) Versiyon Bilgisi -------------------------------------------------------
    $pubspecPath = Join-Path $projectRoot "pubspec.yaml"
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

    Ensure-Dir $distPath

    $verPadded = $currentVersion.PadRight(14)
    Write-Host ""
    Write-Host "+=======================================================+" -ForegroundColor Cyan
    Write-Host "|   GeoGame Build & Deploy  -  Versiyon $verPadded   |" -ForegroundColor Cyan
    Write-Host "+=======================================================+" -ForegroundColor Cyan

    # -- 2) Platform Secim Menusu --------------------------------------------------
    function Show-PlatformMenu {
        $platforms = @(
            [pscustomobject]@{ Name = "Web"; Command = @("flutter", "build", "web", "--release"); Selected = $true }
            [pscustomobject]@{ Name = "APK"; Command = @("flutter", "build", "apk", "--release", "--split-per-abi"); Selected = $true }
            [pscustomobject]@{ Name = "Windows"; Command = @("flutter", "build", "windows", "--release"); Selected = $true }
        )

        $currentIndex = 0
        $menuActive = $true

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
                38 { if ($currentIndex -gt 0) { $currentIndex-- } }  # Up
                40 { if ($currentIndex -lt ($platforms.Count - 1)) { $currentIndex++ } }  # Down
                32 { $platforms[$currentIndex].Selected = -not $platforms[$currentIndex].Selected }  # Space
                13 { $menuActive = $false }  # Enter
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

    # @() ile sarmala - tek eleman secildiginde dizi olarak kalsin
    $selectedNames = @($selectedPlatforms | ForEach-Object { $_.Name })
    Write-Ok "Secilen platformlar: $($selectedNames -join ', ')"

    # -- Flutter Clean (Opsiyonel) -------------------------------------------------
    $doClean = Read-Host "`nOnce 'flutter clean' calistirilsin mi? (E/H)"
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

    # -- 4) APK Kopyalama ---------------------------------------------------------
    if ($selectedNames -contains "APK") {
        Write-Step "APK Dosyalari Kopyalaniyor"

        $flutterApkPath = Join-Path $projectRoot "build\app\outputs\apk\release"
        if (-not (Test-Path $flutterApkPath)) {
            throw "Kaynak APK yolu bulunamadi: $flutterApkPath"
        }

        $apkFiles = Get-ChildItem -Path $flutterApkPath -Filter "*.apk" -Recurse
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

    # -- 5) Windows Installer (Inno Setup) + Imzalama -----------------------------
    if ($selectedNames -contains "Windows") {
        # On kontroller
        if (-not (Test-Path $innoSetupPath)) { throw "Inno Setup bulunamadi: $innoSetupPath" }
        if (-not (Test-Path $issFilePath)) { throw "ISS dosyasi bulunamadi: $issFilePath" }

        Write-Step "Inno Setup Calistiriliyor"
        Run-Exe -FilePath $innoSetupPath -ArgumentList @($issFilePath) -WorkingDirectory $projectRoot

        # Installer .exe dosyasini bul
        $searchPaths = @()
        if (Test-Path $innoOutPath) { $searchPaths += $innoOutPath }
        if (-not ($searchPaths -contains $distPath)) { $searchPaths += $distPath }

        $installerExe = $null

        # Once isim ipucuyla esleseni ara
        foreach ($sp in $searchPaths) {
            $installerExe = Get-ChildItem -Path $sp -Filter "*.exe" -File -ErrorAction SilentlyContinue |
            Where-Object { $_.BaseName -like "*$installerNameHint*" } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
            if ($installerExe) { break }
        }

        # Fallback: en yeni .exe
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

        # Dist'e kopyala
        $installerDest = Join-Path $distPath $installerExe.Name
        if ($installerExe.FullName -ne $installerDest) {
            Copy-Item $installerExe.FullName $installerDest -Force
            $installerExe = Get-Item $installerDest
        }

        $sizeMB = "{0:N2} MB" -f ($installerExe.Length / 1MB)
        Write-Info "Installer: $($installerExe.Name) ($sizeMB)"

        # Imzalama
        if (-not (Test-Path $signtool)) { throw "signtool bulunamadi: $signtool" }
        if (-not (Test-Path $pfxPath)) { throw "PFX bulunamadi: $pfxPath" }

        Write-Step "Installer Imzalaniyor"

        # PFX sifresini pfx.properties dosyasindan oku (password=... satiri)
        $pfxPassPlain = $null
        if (Test-Path $pfxPropertiesPath) {
            $propLine = Get-Content $pfxPropertiesPath | Select-String "^\s*password\s*="
            if ($propLine) {
                $pfxPassPlain = ($propLine.ToString().Split("=", 2)[1]).Trim()
                Write-Info "PFX sifresi pfx.properties dosyasindan okundu."
            }
        }
        # Dosyadan okunamazsa kullanicidan iste
        if ([string]::IsNullOrWhiteSpace($pfxPassPlain)) {
            Write-Warn "pfx.properties bulunamadi veya password satiri yok."
            $pfxPassSecure = Read-Host "PFX password" -AsSecureString
            $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pfxPassSecure)
            $pfxPassPlain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }

        try {

            Run-Exe -FilePath $signtool -ArgumentList @(
                "sign", "/fd", "SHA256",
                "/tr", $timestampUrl, "/td", "SHA256",
                "/f", $pfxPath, "/p", $pfxPassPlain,
                $installerExe.FullName
            )

            Run-Exe -FilePath $signtool -ArgumentList @("verify", "/pa", "/v", $installerExe.FullName)
            Write-Ok "Installer imzalandi ve dogrulandi."
        }
        finally {
            Remove-Variable -Name pfxPassPlain -Force -ErrorAction SilentlyContinue
        }
    }

    # -- 6) Web Dagitim & Git Push -------------------------------------------------
    if ($selectedNames -contains "Web") {
        if (-not (Test-Path $webDeployPath)) { throw "Web deploy yolu bulunamadi: $webDeployPath" }

        $webBuildSrc = Join-Path $projectRoot "build\web"
        if (-not (Test-Path $webBuildSrc)) { throw "Web build ciktisi bulunamadi: $webBuildSrc" }

        Write-Step "Web Senkronizasyonu & Git Push"

        Push-Location $webDeployPath
        try {
            # Mevcut dosyalari temizle (.git haric)
            Get-ChildItem -Force | Where-Object { $_.Name -ne ".git" } | Remove-Item -Recurse -Force

            # Yeni build'i kopyala
            Copy-Item -Path "$webBuildSrc\*" -Destination . -Recurse -Force

            # Git islemleri
            Run-Exe -FilePath "git" -ArgumentList @("add", ".") -WorkingDirectory $webDeployPath

            $commitMsg = "Auto-build V$currentVersion - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
            $commitExit = Run-Exe -FilePath "git" -ArgumentList @("commit", "-m", $commitMsg) -WorkingDirectory $webDeployPath -AllowNonZero
            if ($commitExit -ne 0) {
                Write-Info "Commit atlanmis olabilir (degisiklik yok)."
            }

            Run-Exe -FilePath "git" -ArgumentList @("push", "origin", "main", "--force-with-lease") -WorkingDirectory $webDeployPath
            Write-Ok "Web deploy tamamlandi."
        }
        finally {
            Pop-Location
        }
    }

    # -- 7) GitHub Release (Opsiyonel) ---------------------------------------------
    Write-Host ""
    Write-Host "-- GitHub Release --" -ForegroundColor Cyan
    $createRelease = Read-Host "   GitHub Release olusturulsun mu? (E/H)"

    if ($createRelease -match '^[Ee]$') {
        $releaseFiles = @()

        if ($selectedNames -contains "APK") {
            $apks = Get-ChildItem -Path $distPath -Filter "*.apk" -ErrorAction SilentlyContinue
            foreach ($apk in $apks) { $releaseFiles += $apk.FullName }
        }

        if ($selectedNames -contains "Windows") {
            $exe = Get-ChildItem -Path $distPath -Filter "*.exe" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
            if ($exe) { $releaseFiles += $exe.FullName }
        }

        if ($releaseFiles.Count -eq 0) {
            Write-Warn "Release icin yuklenecek dosya bulunamadi."
        }
        else {
            $tagName = "v$currentVersion"
            $releaseTitle = "GeoGame v$currentVersion"

            Push-Location $projectRoot
            try {
                # Mevcut release var mi kontrol et
                $releaseExists = $false
                try {
                    $null = & gh release view $tagName 2>&1
                    if ($LASTEXITCODE -eq 0) { $releaseExists = $true }
                }
                catch {
                    $releaseExists = $false
                }

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
                    $ghArgs = @("release", "create", $tagName, "--title", $releaseTitle)

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

    # -- Ozet ----------------------------------------------------------------------
    $scriptStopwatch.Stop()

    Write-Host ""
    Write-Host "+=======================================================+" -ForegroundColor Green
    Write-Host "|                     BUILD OZETI                       |" -ForegroundColor Green
    Write-Host "+=======================================================+" -ForegroundColor Green

    foreach ($name in $buildResults.Keys) {
        $r = $buildResults[$name]
        if ($r.Success) { $status = "Basarili" } else { $status = "HATALI" }
        if ($r.Success) { $sColor = "Green" } else { $sColor = "Red" }
        $elapsed = Format-Elapsed $r.Elapsed
        $line = "|  {0,-10}  {1,-12}  {2,-18}  |" -f $name, $status, $elapsed
        Write-Host $line -ForegroundColor $sColor
    }

    # Dist klasorundeki dosyalar
    if (Test-Path $distPath) {
        $distFiles = Get-ChildItem -Path $distPath -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 10
        if ($distFiles) {
            Write-Host "+-------------------------------------------------------+" -ForegroundColor Green
            Write-Host "|  Cikti Dosyalari ($distPath)" -ForegroundColor Green
            foreach ($f in $distFiles) {
                $sizeMB = "{0:N2} MB" -f ($f.Length / 1MB)
                $fLine = "|    {0,-32} {1,10}" -f $f.Name, $sizeMB
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