param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot "backup_config.json")
)

# Funktion 1 - Skapar backupmappen
function New-BackupFolder {
    param(
        [string]$FolderName
    )

    if ($FolderName -notmatch '^[a-zA-Z0-9_-]+$') {
        throw "Ogiltigt mappnamn: $FolderName"
    }

    $folderPath = Join-Path $PSScriptRoot $FolderName

    if (-not (Test-Path -LiteralPath $folderPath -PathType Container)) {
        New-Item -ItemType Directory -Path $folderPath -ErrorAction Stop | Out-Null
        Write-Host "Backupmappen har skapats: $folderPath"
    }
    else {
        Write-Host "Backupmappen finns redan: $folderPath"
    }

    return $folderPath
}

# Funktion 2 - Kopierar filer till backupmappen
function Copy-BackupFiles {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )

    if (-not (Test-Path -LiteralPath $SourcePath -PathType Container)) {
        throw "Källmappen finns inte: $SourcePath"
    }

    $files = @(Get-ChildItem -LiteralPath $SourcePath -File -ErrorAction Stop)

    if ($files.Count -eq 0) {
        throw "Det finns inga filer att säkerhetskopiera."
    }

    foreach ($file in $files) {
        $destination = Join-Path $DestinationPath $file.Name

        Copy-Item -LiteralPath $file.FullName -Destination $destination -ErrorAction Stop

        Write-Host "Kopierad fil: $($file.Name)"
    }

    Write-Host "Backup klar! Antal filer: $($files.Count)"
}

# Funktion 3 - Verifierar säkerhetskopierade filer
function Test-BackupFiles {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )

    $files = @(Get-ChildItem -LiteralPath $SourcePath -File -ErrorAction Stop)

    if ($files.Count -eq 0) {
        throw "Inga filer hittades för verifiering."
    }

    foreach ($file in $files) {
        $backupFile = Join-Path $DestinationPath $file.Name

        if (-not (Test-Path -LiteralPath $backupFile -PathType Leaf)) {
            throw "Backupfilen saknas: $($file.Name)"
        }

        $originalHash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
        $backupHash = (Get-FileHash -LiteralPath $backupFile -Algorithm SHA256 -ErrorAction Stop).Hash

        if ($originalHash -ne $backupHash) {
            throw "Verifiering misslyckades: $($file.Name)"
        }

        Write-Host "Verifierad fil: $($file.Name)"
    }

    Write-Host "Alla $($files.Count) filer har verifierats!"
}

try {
    # Läs konfigurationen från Terraform
    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
        throw "Konfigurationsfilen saknas: $ConfigPath"
    }

    $config = Get-Content -LiteralPath $ConfigPath -Raw -ErrorAction Stop |
        ConvertFrom-Json -ErrorAction Stop

    Write-Host "Projekt: $($config.projektnamn)"
    Write-Host "Backupmapp: $($config.backup_mapp)"

    # Skapa backupmappen
    $backupPath = New-BackupFolder -FolderName $config.backup_mapp

    # Kopiera testfilerna
    $sourcePath = Join-Path $PSScriptRoot "testfiler"

    Copy-BackupFiles -SourcePath $sourcePath -DestinationPath $backupPath
    Test-BackupFiles -SourcePath $sourcePath -DestinationPath $backupPath
}

catch {
    Write-Error "Ett fel uppstod: $($_.Exception.Message)"
    exit 1
}
