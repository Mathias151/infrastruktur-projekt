terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "projektinfo" {
  filename = "${path.module}/projektinfo.txt"
  content  = "Projekt: Automatisk backup\nSyfte: Automatisera säkerhetskopiering av filer.\n"
}
