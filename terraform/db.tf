resource "yandex_compute_instance" "db" {
  name  = "reddit-db-${count.index}"
  labels = {
  tags = "reddit-db"
  }
  count = var.count_of_instances
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      # Указать id образа созданного в предыдущем домашем задании
      image_id = var.db_disk_image
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.app-subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file("~/.ssh/appuser")
  }

  scheduling_policy {
    preemptible = true
  }

  # provisioner "file" {
  #   source      = "files/puma.service"
  #   destination = "/tmp/puma.service"
  # }
  #
  # provisioner "remote-exec" {
  #   script = "files/deploy.sh"
  # }

  depends_on = [ yandex_vpc_subnet.app-subnet ]
}
