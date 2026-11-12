# Enkel automatiserad backup

## 1. Mål

Projektet visar en enkel säkerhetskopiering av två testfiler. **Terraform** skapar inställningarna, **PowerShell** kopierar filerna och **Python** kontrollerar kopiornas innehåll. Terraform och Python är två av teknikerna som ingår i uppgiften.

## 2. Metod

Jag använder Ubuntu via WSL, Terraform, PowerShell 7, Python 3, Git och GitHub.

### Vad filerna gör

- `main.tf`: skapar `projektinfo.txt` och `backup_config.json`.
- `variables.tf`: sparar standardvärden för projektnamn och backupmapp.
- `outputs.tf`: visar backupmappens namn.
- `backup.ps1`: har tre funktioner som skapar mapp, kopierar filer och kontrollerar att kopior finns. Det startar Python efteråt.
- `kontrollera_backup.py`: läser konfigurationen och jämför filernas innehåll.
- `testfiler/`: innehåller originalfilerna.
- `backups/`: skapas av PowerShell och innehåller kopiorna.
- `.gitignore`: gör att tillfälliga och automatiskt skapade filer normalt inte skickas till GitHub.
- `.terraform.lock.hcl`: håller reda på den valda Terraform-provider-versionen.

### Så startas projektet

Öppna projektet i Ubuntu/WSL. Terraform, PowerShell 7 och Python 3 ska vara installerade. Kör i terminalen:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Om Terraform frågar efter godkännande, skriv `yes`. Kör sedan:

```bash
pwsh -NoProfile -File ./backup.ps1
```

PowerShell kör Python automatiskt. Du kan se kopiorna med `ls backups`.

## 3. Resultat

När projektet körs kopieras de två testfilerna till `backups/`. PowerShell kontrollerar att de finns och Python kontrollerar att innehållet är identiskt.

Exempel på utskrift:

```text
2 filer kopierade
Alla filer finns i backupmappen
Python: 2 filer kontrollerade. Innehållet är identiskt.
Backup klar!
```

## 4. Reflektion

Jag har lärt mig hur Terraform skapar en konfigurationsfil som PowerShell och Python använder. Jag har också övat på variabler, funktioner, loopar, villkor och felhantering. Projektet är en enkel övning: jag startar det manuellt och gamla kopior med samma namn skrivs över. Python läser hela testfilernas innehåll för att jämföra det, vilket passar små testfiler men inte är en lösning för mycket stora filer.

### AI och externa källor

Jag har använt ChatGPT som stöd för kodförslag, förenkling, svenska kommentarer, felsökning och README. Jag har även utgått från lärarens instruktioner. Jag behöver själv förstå och kunna förklara koden samt testa den i min Ubuntu/WSL-miljö.

## 5. GitHub-länk

https://github.com/Mathias151/infrastruktur-projekt
