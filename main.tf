# Terraform skapar projektets två lokala filer.
# Dessa filer används som information och konfiguration.
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

# Resurs 1: en textfil som beskriver projektet.
resource "local_file" "projektinfo" {
  filename = "${path.module}/projektinfo.txt"
  content  = "Projekt: ${var.projektnamn}\nSyfte: Automatisera säkerhetskopiering av filer.\n"
}

# Resurs 2: en JSON-fil med inställningar för backupen.
# PowerShell och Python läser denna fil när de körs.
resource "local_file" "backup_config" {
  filename = "${path.module}/backup_config.json"
  content = jsonencode({
    projektnamn = var.projektnamn
    backup_mapp = var.backup_mapp
  })
}
