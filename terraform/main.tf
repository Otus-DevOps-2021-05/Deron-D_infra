provider "yandex" {
  version= "0.35"
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_compute_instance" "app" {
  name = "reddit-app"
  resources {
    cores = 1
    memory = 2
  }
  boot_disk {
    initialize_params {
    # Указать id образа созданного в предыдущем домашнем задании
    image_id = "fd821hvkilmtrb7tbi2n"
    }
  }
  network_interface {
  # Указан id подсети default-ru-central1-a
  subnet_id = "enpv6gbrqnhhbp41jurh"
  nat = true
  }
}
