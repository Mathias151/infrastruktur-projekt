variable "projektnamn" {
  description = "Namnet på projektet"
  type        = string
  default     = "Automatiserad backup"
}

variable "backup_mapp" {
  description = "Mappen där kopiorna sparas"
  type        = string
  default     = "backups"
}
