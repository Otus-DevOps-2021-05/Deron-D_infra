terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
#
provider "yandex" {
  version= "~> 0.35"
  #service_account_key_file = var.service_account_key_file
  #cloud_id                 = var.cloud_id
  #folder_id                = var.folder_id
  #zone                     = var.zone
  #service_account_key_file = "/home/dpp/.yc_keys/key.json"
  #cloud_id  = "b1g5qvsnl7ajk0v5ah5i"
  #folder_id = "b1gu87e4thvariradsue"
}
