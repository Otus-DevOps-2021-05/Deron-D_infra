variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable subnet_id {
  description = "Subnets for modules"
}
variable private_key_path {
  description = "path to private key"
}
variable db_ipaddr {
  description = "Database IP address"
}
variable enable_provision {
  description = "Enable provision"
  # default     = true
}
