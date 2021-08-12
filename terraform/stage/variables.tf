variable cloud_id {
  description = "Cloud"
}
variable folder_id {
  description = "Folder"
}
variable zone {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable subnet_id {
  description = "Subnet"
}
variable service_account_key_file {
  description = "key.json"
}
variable private_key_path {
  description = "Path to private key used for ssh access"
}
variable region_id {
  description = "ID of the availability zone where the network load balancer resides"
  default     = "ru-central1"
}
variable count_of_instances {
  description = "Count of instances"
  default     = 1
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}
variable bucket_name {
  description = "Yandex bucket name"
}
variable access_key {
  description = "Key_id for yandex s3"
}
variable secret_key {
  description = "Secret for yandex s3"
}
variable enable_provision {
  description = "Enable provision"
  default     = true
}
