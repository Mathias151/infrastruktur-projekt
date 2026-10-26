param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot "backup_config.json")
)

# Funktion 1: skapa backupmappen
function New-BackupFolder {
    param([string]$FolderName)

    if ($FolderName -notmatch '^[a-zA-Z0-9_-]+$') {
        throw "Ogiltigt mappnamn"
    }

    $path = Join-Path $PSScriptRoot $FolderName

    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        New-Item -ItemType Directory -Path $path -ErrorAction Stop | Out-Null
    }

    return $path
}

# Funktion 2: kopiera testfilerna
function Copy-BackupFiles {
    param([string]$Source, [string]$Destination)

    $files = @(Get-ChildItem -LiteralPath $Source -File -ErrorAction Stop)

    if ($files.Count -eq 0) {
        throw "Inga filer att kopiera"
    }

    foreach ($file in $files) {
        $target = Join-Path $Destination $file.Name
        Copy-Item -LiteralPath $file.FullName -Destination $target -Force -ErrorAction Stop
    }

    Write-Host "$($files.Count) filer kopierade"
}

# Funktion 3: kontrollera att kopiorna finns
function Test-BackupFiles {
    param([string]$Source, [string]$Destination)

    $files = @(Get-ChildItem -LiteralPath $Source -File -ErrorAction Stop)

    foreach ($file in $files) {
        $target = Join-Path $Destination $file.Name

        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
            throw "Backupfil saknas: $($file.Name)"
        }
    }

    Write-Host "Alla filer finns i backupmappen"
}

# Huvudprogram: Terraform -> PowerShell
try {
    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
        throw "Konfigurationsfilen saknas"
    }

    $config = Get-Content -LiteralPath $ConfigPath -Raw -ErrorAction Stop |
        ConvertFrom-Json -ErrorAction Stop

    $source = Join-Path $PSScriptRoot "testfiler"
    $destination = New-BackupFolder -FolderName $config.backup_mapp

    Copy-BackupFiles -Source $source -Destination $destination
    Test-BackupFiles -Source $source -Destination $destination

    Write-Host "Backup klar!"
}
catch {
    Write-Error "Fel: $($_.Exception.Message)"
    exit 1
}
