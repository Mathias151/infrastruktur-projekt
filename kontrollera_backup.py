"""Kontrollerar att backupfilerna har samma innehåll som originalen."""

import filecmp
import json
import sys
from pathlib import Path


def kontrollera_backup():
    # Hitta projektmappen, oavsett var terminalen är öppnad.
    projektmapp = Path(__file__).resolve().parent

    # Läs mappnamnet från filen som Terraform har skapat.
    config_fil = projektmapp / "backup_config.json"
    config = json.loads(config_fil.read_text(encoding="utf-8"))

    originalmapp = projektmapp / "testfiler"
    backupmapp = projektmapp / config["backup_mapp"]

    # Kontrollera att mapparna finns innan vi jämför filerna.
    if not originalmapp.is_dir() or not backupmapp.is_dir():
        raise FileNotFoundError("Testmappen eller backupmappen saknas")

    filer = sorted(fil for fil in originalmapp.iterdir() if fil.is_file())
    if not filer:
        raise ValueError("Inga testfiler hittades")

    # Gå igenom filerna en i taget och jämför deras innehåll.
    for original in filer:
        kopia = backupmapp / original.name
        if not kopia.is_file():
            raise FileNotFoundError(f"Backupfil saknas: {original.name}")

        # shallow=False betyder att även filernas innehåll jämförs.
        if not filecmp.cmp(original, kopia, shallow=False):
            raise ValueError(f"Olika innehåll i filen: {original.name}")

    print(f"Python: {len(filer)} filer kontrollerade. Innehållet är identiskt.")


# Starta funktionen när filen körs med python3 kontrollera_backup.py.
if __name__ == "__main__":
    try:
        kontrollera_backup()
    except (OSError, ValueError, KeyError, TypeError) as fel:
        print(f"Python-kontroll misslyckades: {fel}", file=sys.stderr)
        sys.exit(1)
