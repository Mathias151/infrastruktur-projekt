# Detta skript kopierar testfiler till en backupmapp.
# Terraform måste ha skapat backup_config.json innan vi kör skriptet.

# Funktion 1: Skapa backupmappen om den inte finns.
function Skapa-Backupmapp {
    param([string]$Namn)

    # Bara enkla mappnamn får användas (bokstäver, siffror, _ och -).
    if ($Namn -notmatch '^[a-zA-Z0-9_-]+$') {
        throw "Felaktigt namn på backupmappen"
    }

    $Mapp = Join-Path $PSScriptRoot $Namn
    if (-not (Test-Path -LiteralPath $Mapp -PathType Container)) {
        New-Item -ItemType Directory -Path $Mapp -ErrorAction Stop | Out-Null
    }
    return $Mapp
}

# Funktion 2: Kopiera filerna en i taget.
function Kopiera-Filer {
    param([string]$Fran, [string]$Till)

    $Filer = @(Get-ChildItem -LiteralPath $Fran -File -ErrorAction Stop)
    if ($Filer.Count -eq 0) {
        throw "Inga testfiler hittades"
    }

    # foreach går igenom varje fil i listan.
    foreach ($Fil in $Filer) {
        Copy-Item -LiteralPath $Fil.FullName -Destination $Till -Force -ErrorAction Stop
    }
    Write-Host "$($Filer.Count) filer kopierade"
}

# Funktion 3: Kontrollera att kopiorna finns.
function Kontrollera-Kopior {
    param([string]$Fran, [string]$Till)

    foreach ($Fil in (Get-ChildItem -LiteralPath $Fran -File -ErrorAction Stop)) {
        $Kopia = Join-Path $Till $Fil.Name
        if (-not (Test-Path -LiteralPath $Kopia -PathType Leaf)) {
            throw "Kopian saknas: $($Fil.Name)"
        }
    }
    Write-Host "Alla filer finns i backupmappen"
}

# Huvudprogrammet: Kör funktionerna i rätt ordning.
try {
    $ConfigFil = Join-Path $PSScriptRoot "backup_config.json"
    if (-not (Test-Path -LiteralPath $ConfigFil -PathType Leaf)) {
        throw "Konfiguration saknas. Kör terraform apply först."
    }
    $Config = Get-Content -LiteralPath $ConfigFil -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop

    $Fran = Join-Path $PSScriptRoot "testfiler"
    $Till = Skapa-Backupmapp -Namn $Config.backup_mapp
    Kopiera-Filer -Fran $Fran -Till $Till
    Kontrollera-Kopior -Fran $Fran -Till $Till

    # Python kontrollerar också att filernas innehåll är likadant.
    & python3 (Join-Path $PSScriptRoot "kontrollera_backup.py")
    if ($LASTEXITCODE -ne 0) {
        throw "Python-kontrollen misslyckades"
    }
    Write-Host "Backup klar!"
}
catch {
    Write-Error "Fel: $($_.Exception.Message)"
    exit 1
}
