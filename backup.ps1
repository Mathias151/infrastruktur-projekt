# PowerShell utför backupen. Terraform ska köras först och skapa JSON-filen.
# $PSScriptRoot betyder mappen där backup.ps1 ligger.
param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot "backup_config.json")
)

# Funktion 1: skapa backupmappen om den inte redan finns.
function New-BackupFolder {
    param([string]$FolderName)

    # Tillåt bara ett enkelt mappnamn, inte en godtycklig sökväg.
    if ($FolderName -notmatch '^[a-zA-Z0-9_-]+$') {
        throw "Ogiltigt mappnamn"
    }

    $path = Join-Path $PSScriptRoot $FolderName

    # -not betyder "inte". Om mappen saknas skapas den.
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        New-Item -ItemType Directory -Path $path -ErrorAction Stop | Out-Null
    }
    return $path
}

# Funktion 2: kopiera alla filer från testfiler till backupmappen.
function Copy-BackupFiles {
    param([string]$Source, [string]$Destination)

    # @() ger en lista (array) även om mappen bara har en fil.
    $files = @(Get-ChildItem -LiteralPath $Source -File -ErrorAction Stop)
    if ($files.Count -eq 0) {
        throw "Inga filer att kopiera"
    }

    # foreach gör samma sak för varje fil. -Force skriver över gamla kopior.
    foreach ($file in $files) {
        $target = Join-Path $Destination $file.Name
        Copy-Item -LiteralPath $file.FullName -Destination $target -Force -ErrorAction Stop
    }

    Write-Host "$($files.Count) filer kopierade"
}

# Funktion 3: kontrollera att varje kopierad fil finns.
function Test-BackupFiles {
    param([string]$Source, [string]$Destination)

    $files = @(Get-ChildItem -LiteralPath $Source -File -ErrorAction Stop)
    foreach ($file in $files) {
        $target = Join-Path $Destination $file.Name

        # -PathType Leaf betyder att sökvägen ska vara en fil.
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
            throw "Backupfil saknas: $($file.Name)"
        }
    }

    Write-Host "Alla filer finns i backupmappen"
}

# Huvudprogram: läs Terraform-filen, gör backup och kontrollera resultatet.
try {
    # try försöker köra stegen; catch nedan tar hand om fel.
    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
        throw "Konfigurationsfilen saknas. Kör terraform apply först."
    }

    # ConvertFrom-Json gör om JSON-text till värden PowerShell kan läsa.
    $config = Get-Content -LiteralPath $ConfigPath -Raw -ErrorAction Stop |
        ConvertFrom-Json -ErrorAction Stop

    $source = Join-Path $PSScriptRoot "testfiler"
    $destination = New-BackupFolder -FolderName $config.backup_mapp

    Copy-BackupFiles -Source $source -Destination $destination
    Test-BackupFiles -Source $source -Destination $destination

    # Python gör en extra kontroll: är innehållet i filerna identiskt?
    $pythonScript = Join-Path $PSScriptRoot "kontrollera_backup.py"
    if (-not (Test-Path -LiteralPath $pythonScript -PathType Leaf)) {
        throw "Python-filen kontrollera_backup.py saknas"
    }
    & python3 $pythonScript
    if ($LASTEXITCODE -ne 0) {
        throw "Python-kontrollen misslyckades"
    }

    Write-Host "Backup klar!"
}
catch {
    # Om ett steg misslyckas visas felet och skriptet avslutas.
    Write-Error "Fel: $($_.Exception.Message)"
    exit 1
}
