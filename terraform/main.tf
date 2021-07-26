# terraform {
#   required_version = "0.12.8"
# }

provider "yandex" {
  version                  = "0.35"
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}
