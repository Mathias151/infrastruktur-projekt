terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

# Resurs 1: projektinformation
resource "local_file" "projektinfo" {
  filename = "${path.module}/projektinfo.txt"
  content  = "Projekt: ${var.projektnamn}\nSyfte: Automatisera säkerhetskopiering av filer.\n"
}

# Resurs 2: konfiguration som PowerShell läser
resource "local_file" "backup_config" {
  filename = "${path.module}/backup_config.json"
  content = jsonencode({
    projektnamn = var.projektnamn
    backup_mapp = var.backup_mapp
  })
}
