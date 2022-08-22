terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "${var.yandex_cloud_id}"
  folder_id = "${var.yandex_folder_id}"
  zone      = "${var.yandex_zone}"
}

locals {
  instances_type_map_image = {
    prod = "${var.ubuntu2004lts}"
    stage = "${var.ubuntu1604lts}"
  }
}


resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      // Если prod то образ 2004lts иначе 1604lts
      image_id    =  local.instances_type_map_image[terraform.workspace]
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    #ssh-keys = "ubuntu:${file("~/keys_ssh.pub")}"
    user-data = "${file("./meta.txt")}"
  }
}

#resource "yandex_compute_instance" "vm-2" {
#  name = "terraform2"
#
#  resources {
#    cores  = 1
#    memory = 1
#  }
#
#  boot_disk {
#    initialize_params {
#      image_id = "fd8j0himen71r665h761"
#    }
#  }
#
#  network_interface {
#    subnet_id = yandex_vpc_subnet.subnet-1.id
#    nat       = true
#  }
#
#  metadata = {
#    ssh-keys = "ubuntu:${file("~/keys_ssh.pub")}"
#  }
#}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

#output "internal_ip_address_vm_2" {
#  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
#}


output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

#output "external_ip_address_vm_2" {
#  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
#}
