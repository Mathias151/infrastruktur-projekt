# Python kontrollerar att filerna i backupen har samma innehåll som originalen.
import json
import sys
from pathlib import Path

# Hitta mapparna i projektet.
projektmapp = Path(__file__).parent

try:
    # Läs backupmappens namn från filen som Terraform skapat.
    config = json.loads((projektmapp / "backup_config.json").read_text(encoding="utf-8"))
    originalmapp = projektmapp / "testfiler"
    backupmapp = projektmapp / config["backup_mapp"]

    # Gör en lista med filerna som ska kontrolleras.
    filer = [fil for fil in originalmapp.iterdir() if fil.is_file()]
    if len(filer) == 0:
        raise ValueError("Inga testfiler hittades")

    # Jämför varje originalfil med motsvarande kopia.
    for fil in filer:
        kopia = backupmapp / fil.name
        if not kopia.is_file() or fil.read_bytes() != kopia.read_bytes():
            raise ValueError(f"Backupfil saknas eller skiljer sig: {fil.name}")

    print(f"Python: {len(filer)} filer kontrollerade. Innehållet är identiskt.")
except (OSError, ValueError, KeyError, TypeError) as fel:
    # Skicka felkod 1 så att PowerShell vet att kontrollen misslyckades.
    print(f"Fel i Python: {fel}", file=sys.stderr)
    sys.exit(1)
