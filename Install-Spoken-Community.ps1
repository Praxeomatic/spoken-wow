# Unofficial Spoken subtitle-grabber build for WoW Forever.
# Downloads the community branch, backs up replaced addon folders, and leaves voice packs and SavedVariables alone.
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$AddOnsPath
)

$ErrorActionPreference = 'Stop'
$names = @('Spoken', 'Spoken_Quests', 'Spoken_Places', 'Spoken_Readables', 'Spoken_Bosses', 'SpokenContributions')
$source = 'https://github.com/Praxeomatic/spoken-wow/archive/refs/heads/community/subtitle-grabber.zip'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$logDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "SpokenCommunityInstallLogs\$stamp"
$backupDir = Join-Path $logDir 'Backup'
$stage = Join-Path $env:TEMP "SpokenCommunity-$stamp-$PID"
$zipPath = Join-Path $stage 'community.zip'
$changed = New-Object 'System.Collections.Generic.List[string]'
$backupComplete = $false
$transcribing = $false
$failed = $false

New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
try {
    Start-Transcript -Path (Join-Path $logDir 'Install.log') -Force | Out-Null
    $transcribing = $true
    $addons = [System.IO.Path]::GetFullPath($AddOnsPath.Trim('"'))
    if ([System.IO.Path]::GetFileName($addons.TrimEnd('\', '/')) -ne 'AddOns' -or
        -not (Test-Path -LiteralPath $addons -PathType Container)) {
        throw 'Pass the existing WoW Forever Interface\AddOns directory with -AddOnsPath.'
    }
    $running = @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessName -match '^(Wow|WowClassic|Wow-64|WowForever|World of Warcraft)$'
    })
    if ($running.Count) { throw 'WoW appears to be running. Close the game before installing.' }

    New-Item -ItemType Directory -Path $stage -Force | Out-Null
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Write-Host "Downloading unofficial Spoken community build..."
    Invoke-WebRequest -Uri $source -OutFile $zipPath -UseBasicParsing

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
        $entries = @($archive.Entries | Where-Object { $_.Name -ne '' })
        if (-not $entries.Count) { throw 'Downloaded ZIP contains no files.' }
        $rootName = ($entries[0].FullName -replace '\\', '/').Split('/')[0]
        foreach ($entry in $entries) {
            $path = $entry.FullName -replace '\\', '/'
            $parts = $path.Split('/')
            if (-not $path.StartsWith("$rootName/") -or
                $path.Contains(':') -or
                @($parts | Where-Object { $_ -eq '.' -or $_ -eq '..' }).Count -gt 0) {
                throw "Unsafe ZIP entry: $path"
            }
            if ($names -cnotcontains $parts[1] -and
                @('README.md', 'LICENSE', 'THIRD_PARTY.md', 'Install-Spoken-Community.ps1') -cnotcontains $parts[1]) {
                throw "Unexpected ZIP entry: $path"
            }
        }
        foreach ($name in $names) {
            $manifest = "$rootName/$name/$name.toc"
            if (-not @($entries | Where-Object { $_.FullName -eq $manifest }).Count) {
                throw "Missing manifest: $manifest"
            }
        }
        if (-not @($entries | Where-Object { $_.FullName -eq "$rootName/Spoken/UI/Subtitle.lua" }).Count) {
            throw 'Missing patched subtitle code.'
        }
    } finally {
        $archive.Dispose()
    }

    Expand-Archive -LiteralPath $zipPath -DestinationPath $stage -Force
    $root = Join-Path $stage $rootName
    foreach ($name in $names) {
        $toc = Join-Path (Join-Path $root $name) "$name.toc"
        if (-not (Test-Path -LiteralPath $toc -PathType Leaf)) {
            throw "Extraction incomplete: $toc"
        }
    }

    Write-Host "Target: $addons"
    Write-Host "Backup: $backupDir"
    # Complete the backups before replacing any installed folder.
    foreach ($name in $names) {
        $existing = Join-Path $addons $name
        if (Test-Path -LiteralPath $existing) {
            Copy-Item -LiteralPath $existing -Destination (Join-Path $backupDir $name) -Recurse -Force
        }
    }
    $backupComplete = $true
    foreach ($name in $names) {
        $existing = Join-Path $addons $name
        $changed.Add($name)
        if (Test-Path -LiteralPath $existing) { Remove-Item -LiteralPath $existing -Recurse -Force }
        Copy-Item -LiteralPath (Join-Path $root $name) -Destination $existing -Recurse -Force
        if (-not (Test-Path -LiteralPath (Join-Path $existing "$name.toc") -PathType Leaf)) {
            throw "Installation verification failed: $name"
        }
    }
    Write-Host 'Installed all six Spoken addon folders.' -ForegroundColor Green
    Write-Host 'Existing external voice packs and account SavedVariables were left unchanged.'
} catch {
    $failed = $true
    Write-Host "Installation failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($backupComplete) {
        foreach ($name in $changed) {
            try {
                $existing = Join-Path $addons $name
                $saved = Join-Path $backupDir $name
                if (Test-Path -LiteralPath $existing) { Remove-Item -LiteralPath $existing -Recurse -Force }
                if (Test-Path -LiteralPath $saved) {
                    Copy-Item -LiteralPath $saved -Destination $existing -Recurse -Force
                }
            } catch {
                Write-Host "Rollback failed for $name : $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
} finally {
    if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue }
    if ($transcribing) { Stop-Transcript | Out-Null }
    Start-Process explorer.exe -ArgumentList ('"' + $logDir + '"')
}
if ($failed) { exit 1 }
