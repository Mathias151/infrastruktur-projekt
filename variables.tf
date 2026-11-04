# En variabel är ett värde som går att ändra utan att skriva om huvudkoden.
variable "projektnamn" {
  description = "Namnet på projektet"
  type        = string
  default     = "Automatiserad backup"
}

# Namnet på mappen där PowerShell sparar kopiorna.
variable "backup_mapp" {
  description = "Mappen där kopiorna sparas"
  type        = string
  default     = "backups"
}
