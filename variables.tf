variable "projektnamn" {
  description = "Namnet på backup-projektet"
  type        = string
  default     = "Automatiserad backup"
}

variable "backup_mapp" {
  description = "Namnet på mappen där backup ska sparas"
  type        = string
  default     = "backups"
}
