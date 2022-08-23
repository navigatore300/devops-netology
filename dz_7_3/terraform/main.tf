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
    prod = "${var.ubuntu2004lts}",
    stage = "${var.ubuntu1604lts}"
  }
  instances_map_count = {
    prod = 2,
    stage  = 1
  }
}


resource "yandex_compute_instance" "vm-count" {
  name = "terraform-${terraform.workspace}-${count.index}"

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
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
  }

  // Для п.4 Добавим count.
  count = local.instances_map_count[terraform.workspace]

  metadata = {
    #ssh-keys = "ubuntu:${file("~/keys_ssh.pub")}"
    user-data = "${file("./meta.txt")}"
  }
    //п.6
  lifecycle {
    create_before_destroy = true
  }

}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

locals {
  instance_for_each_map = {
    stage = {
      "vm1" = { core = 2, memory = 2},
    },
    prod = {
      "vm1" = { core = 2, memory = 2},
      "vm2" = { core = 4, memory = 4},
    }
  }
}

resource "yandex_compute_instance" "vm-foreach" {
  //п.5. определите их количество при помощи for_each, а не count.
  for_each = local.instance_for_each_map[terraform.workspace]
  name     = "foreach-test-${terraform.workspace}-${each.key}"
  resources {
    cores  = each.value.core
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      // Если prod то образ 2004lts иначе 1604lts
      image_id    =  local.instances_type_map_image[terraform.workspace]
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
  }
}
#output "internal_ip_address_vm_1" {
#  value = yandex_compute_instance.vm-1[count.index]
#}

#output "internal_ip_address_vm_2" {
#  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
#}


#output "external_ip_address_vm_1" {
#  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
#}

#output "external_ip_address_vm_2" {
#  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
#}
