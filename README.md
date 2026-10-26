# Automatiserad backup med Terraform och PowerShell

## 1. Mål
Målet är att automatisera en enkel backup av två testfiler. Terraform skapar konfigurationen och PowerShell använder den för att kopiera filer till en backupmapp och kontrollera resultatet.

## 2. Metod
Projektet körs i Ubuntu via WSL2 och använder **Terraform**, **PowerShell 7** och **Git**.

- `main.tf`: två Terraform-resurser som skapar `projektinfo.txt` och `backup_config.json`.
- `variables.tf`: projektets namn och namnet på backupmappen.
- `outputs.tf`: visar namnet på backupmappen.
- `backup.ps1`: tre funktioner som skapar mappen, kopierar testfiler och kontrollerar att kopiorna finns.
- `testfiler/`: två enkla textfiler för test.

### Kör projektet steg för steg
Öppna en Ubuntu/WSL-terminal i projektmappen och kör:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Svara `yes` om Terraform frågar om ändringarna ska genomföras.

Kör sedan PowerShell-skriptet:

```bash
pwsh -NoProfile -File ./backup.ps1
```

Du kan kontrollera resultatet genom att öppna mappen `backups/`.

## 3. Resultat
När Terraform har körts skapas konfigurationsfilerna. När PowerShell-skriptet körs kopieras `test1.txt` och `test2.txt` från `testfiler/` till `backups/`.

Exempel på utskrift vid en lyckad körning:

```text
2 filer kopierade
Alla filer finns i backupmappen
Backup klar!
```

Verifieringen kontrollerar att kopiorna **finns**. Den kontrollerar inte att innehållet är identiskt.

## 4. Reflektion
Jag har lärt mig hur Terraform kan skapa en konfigurationsfil som ett PowerShellskript som man sedan använder. Jag har också tränat på funktioner med parametrar, loopar, villkor och `try/catch` för felhantering.

Det viktiga var att testa en del i taget så att jag förstod vad varje kommando gjorde. Lösningen är enkel, men den fungerar för testfiler och går att köra igen.

## 5. GitHub-länk
https://github.com/Mathias151/infrastruktur-projekt.git
