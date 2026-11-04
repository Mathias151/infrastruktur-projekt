# Automatiserad backup med Terraform, PowerShell och Python

## 1. Mål

Jag har gjort ett enkelt projekt som automatiskt säkerhetskopierar två testfiler.
Terraform skapar konfigurationen, PowerShell kopierar filerna och Python kontrollerar att kopiorna har samma innehåll som originalen.
Projektet är gjort för att visa grundläggande automatisering i en IT-miljö.

## 2. Metod

Jag använder **Ubuntu via WSL2**, **Terraform**, **PowerShell 7**, **Python 3** och **Git/GitHub**.

### Vad filerna gör

- `main.tf` – har två resurser som skapar `projektinfo.txt` och `backup_config.json`.
- `variables.tf` – innehåller projektets namn och namnet på backupmappen.
- `outputs.tf` – visar backupmappens namn efter att Terraform körts.
- `backup.ps1` – har tre funktioner: skapa mapp, kopiera filer och kontrollera att kopior finns. Skriptet startar även Python-kontrollen.
- `kontrollera_backup.py` – använder Python för att jämföra innehållet i originalfiler och backupfiler.
- `testfiler/` – innehåller de två testfilerna som kopieras.
- `.gitignore` – hindrar genererade filer från att hamna i GitHub.

### Installation och körning

Det behövs Terraform, PowerShell 7 (`pwsh`) och Python 3 (`python3`) i Ubuntu/WSL. Python använder bara standardbiblioteket, så inga extra Python-paket behövs.

Öppna terminalen i projektmappen och kör:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Skriv `yes` om Terraform frågar om du vill genomföra ändringarna. Terraform skapar nu `projektinfo.txt` och `backup_config.json`.

Kör sedan:

```bash
pwsh -NoProfile -File ./backup.ps1
```

PowerShell kopierar filerna och startar Python automatiskt. Du kan också köra kontrollen separat:

```bash
python3 kontrollera_backup.py
```

Du kan visa de kopierade filerna med `ls backups`.

**Ordningen är:** Terraform → PowerShell → Python.

## 3. Resultat

När allt fungerar skapas mappen `backups` och de två filerna kopieras dit. PowerShell kontrollerar att kopiorna finns och Python jämför deras innehåll.

Exempel på lyckad utskrift (kontrolleras vid sluttest):

```text
2 filer kopierade
Alla filer finns i backupmappen
Python: 2 filer kontrollerade. Innehållet är identiskt.
Backup klar!
```

Kör jag skriptet igen skrivs kopior med samma namn över. Om ett steg misslyckas får jag ett felmeddelande.

## 4. Reflektion

Jag har lärt mig hur Terraform skapar konfigurationsfiler och hur PowerShell kan använda dem. Jag har övat på funktioner, parametrar, arrayer, loopar, villkor och felhantering i PowerShell. Python används för en enkel men tydlig kontroll av att backupens innehåll stämmer.

En begränsning är att skriptet måste startas manuellt och att gamla kopior skrivs över. För den här uppgiften har jag valt att hålla lösningen enkel och begriplig.

### AI och externa källor

Jag har använt ChatGPT som stöd för idéer, kodförslag, kommentarer och felsökning. Jag använder tester i Ubuntu/WSL för att kontrollera kodförslagen.

## 5. GitHub-länk

https://github.com/Mathias151/infrastruktur-projekt
