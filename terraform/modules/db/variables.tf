variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}
variable subnet_id {
  description = "Subnets for modules"
}
variable private_key_path {
  description = "path to private key"
}
variable enable_provision {
  description = "Enable provision"
  default     = true
}
