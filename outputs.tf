output "projektinfo_fil" {
  description = "Sökvägen till projektinformationen"
  value       = local_file.projektinfo.filename
}

output "backup_config_fil" {
  description = "Sökvägen till backup-konfigurationen"
  value       = local_file.backup_config.filename
}

output "backup_mapp" {
  description = "Namnet på backupmappen"
  value       = var.backup_mapp
}
