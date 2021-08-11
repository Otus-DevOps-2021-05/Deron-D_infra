terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "otus-bucket"
    region     = "ru-central1-a"
    key        = "terraform.tfstate"
    # access_key = var.access_key
    # secret_key = var.secret_key
    access_key = "pnT02nSkjjDaNAhQ8EWd"
    secret_key = "WGJC6UdKBTozEitYv-Yt074HTUaJ9RaklXhQB8LX"
    
    skip_region_validation      = true
    skip_credentials_validation = true
   }
}
