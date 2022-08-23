# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
терраформа и aws. 

1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано 
[здесь](https://www.terraform.io/docs/backends/types/s3.html).
1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше. 
----

__Ответ:__

Задания выполнил в Яндекс Облаке.
Создал вручную бакет, к существующему служебному аккаунту сгенерировал статический ключ. 
Прописал настройки для бэкэнда в файле backend.tf, который поместил под .gitignore, так как в нем нужно передавать секретный ключ.

Структура файла такая:

```
terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "dz-7-3-terraform-backend"
    region     = "ru-central1"
    key        = "terraform/terraform.tfstate"
    access_key = "<id ключа>"
    secret_key = "<секретный ключ>"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
```

## Задача 2. Инициализируем проект и создаем воркспейсы. 

1. Выполните `terraform init`:
    * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице 
dynamodb.
    * иначе будет создан локальный файл со стейтами.  
1. Создайте два воркспейса `stage` и `prod`.
1. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах 
использовались разные `instance_type`.
1. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 
1. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
1. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
1. При желании поэкспериментируйте с другими параметрами и рессурсами.

В виде результата работы пришлите:
* Вывод команды `terraform workspace list`.
* Вывод команды `terraform plan` для воркспейса `prod`.  

---

__Ответ:__
Вывод команды `terraform workspace list`.
```
userr@HP-ProBook:~/PycharmProjects/devops-netology/dz_7_3/terraform$ terraform workspace list
  default
* prod
  stage
```
В яндекс облаке нет пресетов, поэтому реализовал изменение конфига машины (в моем случае разный образ диска):
```shell
locals {
  instances_type_map_image = {
    prod = "${var.ubuntu2004lts}"
    stage = "${var.ubuntu1604lts}"
  }
}
```
Результат работы виде в разнице вывода `terraform plan`
```shell
terraform plan > stage_plan.txt
terraform workspace select prod
Switched to workspace "prod".
terraform plan > prod_plan.txt
diff prod_plan.txt stage_plan.txt 
43c43
<               + image_id    = "f2ej3v69sukaa9c7p0vt"
---
>               + image_id    = "fd8j0himen71r665h761"

```
После внесения `count` команда `terraform plan` прогнозируемо имеет разницу в выводе:
```
userr@HP-ProBook:~/PycharmProjects/devops-netology/dz_7_3/terraform$ terraform plan | grep name
      + hostname                  = (known after apply)
                  - name: userr
      + name                      = "terraform-prod-0"
          + device_name = (known after apply)
              + name        = (known after apply)
      + hostname                  = (known after apply)
                  - name: userr
      + name                      = "terraform-prod-1"
          + device_name = (known after apply)
              + name        = (known after apply)
      + name                      = "network1"
      + name           = "subnet1"
      
userr@HP-ProBook:~/PycharmProjects/devops-netology/dz_7_3/terraform$ terraform workspace list
  default
* prod
  stage

userr@HP-ProBook:~/PycharmProjects/devops-netology/dz_7_3/terraform$ terraform workspace select stage
Switched to workspace "stage".

userr@HP-ProBook:~/PycharmProjects/devops-netology/dz_7_3/terraform$ terraform plan | grep name
      + hostname                  = (known after apply)
                  - name: userr
      + name                      = "terraform-stage-0"
          + device_name = (known after apply)
              + name        = (known after apply)
      + name                      = "network1"
      + name           = "subnet1"

```
Добавил `foreach` в котором в зависимость от воркспейса изменяется количество машин и их характеристики (ядра и память).  
```shell
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
```
Теперь вывод: 
```shell
userr@HP-ProBook:~/PycharmProjects/devops-netology/dz_7_3/terraform$ terraform plan | grep name
      + hostname                  = (known after apply)
                  - name: userr
      + name                      = "terraform-stage-0"
          + device_name = (known after apply)
              + name        = (known after apply)
      + hostname                  = (known after apply)
      + name                      = "foreach-test-stage-vm1"
          + device_name = (known after apply)
              + name        = (known after apply)
      + name                      = "network1"
      + name           = "subnet1"
userr@HP-ProBook:~/PycharmProjects/devops-netology/dz_7_3/terraform$ terraform workspace select prod
Switched to workspace "prod".
userr@HP-ProBook:~/PycharmProjects/devops-netology/dz_7_3/terraform$ terraform plan | grep name
      + hostname                  = (known after apply)
                  - name: userr
      + name                      = "terraform-prod-0"
          + device_name = (known after apply)
              + name        = (known after apply)
      + hostname                  = (known after apply)
                  - name: userr
      + name                      = "terraform-prod-1"
          + device_name = (known after apply)
              + name        = (known after apply)
      + hostname                  = (known after apply)
      + name                      = "foreach-test-prod-vm1"
          + device_name = (known after apply)
              + name        = (known after apply)
      + hostname                  = (known after apply)
      + name                      = "foreach-test-prod-vm2"
          + device_name = (known after apply)
              + name        = (known after apply)
      + name                      = "network1"
      + name           = "subnet1"

```

Добавил блок:  
```shell
  lifecycle {
    create_before_destroy = true
  }
```
Файлы terraform в [папке](https://github.com/navigatore300/devops-netology/tree/main/dz_7_3/terraform) 
