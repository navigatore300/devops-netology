
# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

---

## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.
- Какой из принципов IaaC является основополагающим?

_Ответ :_

Преимущество применения на практике инфраструктуры как кода заключается в том:
- что при миграции и развертывании инфраструктуры на другой площадке она будет повторять ровно ту, 
что была описана кодом,  
- оперативность развертывания при масштабировании,
- среда разработки, тестирования и работы системы легко развертываются.

Главный принцип IaaC идемпотентность - результат и свойтва не зависят от количества выполнения кода.
## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

_Ответ :_

Преимущества Ansible по сравнению с другими аналогичными решениями заключаются в следующем:

- на управляемые узлы не нужно устанавливать никакого дополнительного ПО, всё работает через SSH;
- код программы, написанный на Python, очень прост; 
- при необходимости написание дополнительных модулей не составляет особого труда;
- язык, на котором пишутся сценарии, также предельно прост;
- низкий порог вхождения: обучиться работе с Ansible можно за очень короткое время;
- документация к продукту написана очень подробно и вместе с тем — просто и понятно; она регулярно обновляется;
- Ansible работает не только в режиме push, но и pull, как это делают большинство систем управления (Puppet, Chef);
- имеется возможность последовательного обновления состояния узлов (rolling update).

На мой взгляд pull позволяет более наглядно контролировать выполнение, но в случае большого количества управляемых машин. 

## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*


- VirtualBox Install
```
sudo touch /etc/apt/sources.list.d/oracle-virtualbox.list
sudo echo "deb https://download.virtualbox.org/virtualbox/debian buster contrib" >> deb https://download.virtualbox.org/virtualbox/debian buster contrib
sudo wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y gnupg2
sudo apt-get dist-upgrade
sudo reboot
sudo apt-get install linux-headers-$(uname -r)
sudo apt-get install virtualbox-6.1
```
- Vagrant Install
```
apt update
apt install curl apt-add-repository software-properties-common
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update && sudo apt install vagrant
```
- Ansible Install
```
pip3 install ansible
```
![](img/dz5_2_pic1.png)
## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
```
docker ps
```

_Ответ :_
```angular2html
userr@deb10:~/src1/vagrant$ vagrant up
Bringing machine 'server1.netology' up with 'virtualbox' provider...
==> server1.netology: Clearing any previously set forwarded ports...
==> server1.netology: Clearing any previously set network interfaces...
==> server1.netology: Preparing network interfaces based on configuration...
    server1.netology: Adapter 1: nat
    server1.netology: Adapter 2: hostonly
==> server1.netology: Forwarding ports...
    server1.netology: 22 (guest) => 20011 (host) (adapter 1)
    server1.netology: 22 (guest) => 2222 (host) (adapter 1)
==> server1.netology: Running 'pre-boot' VM customizations...
==> server1.netology: Booting VM...
==> server1.netology: Waiting for machine to boot. This may take a few minutes...
    server1.netology: SSH address: 127.0.0.1:2222
    server1.netology: SSH username: vagrant
    server1.netology: SSH auth method: private key


==> server1.netology: Machine booted and ready!
==> server1.netology: Checking for guest additions in VM...
==> server1.netology: Setting hostname...
==> server1.netology: Configuring and enabling network interfaces...
==> server1.netology: Mounting shared folders...
    server1.netology: /vagrant => /home/userr/src1/vagrant
==> server1.netology: Running provisioner: ansible...
    server1.netology: Running ansible-playbook...

PLAY [nodes] *******************************************************************

TASK [Gathering Facts] *********************************************************
ok: [server1.netology]

TASK [Create directory for ssh-keys] *******************************************
ok: [server1.netology]

TASK [Adding rsa-key in /root/.ssh/authorized_keys] ****************************
changed: [server1.netology]

TASK [Checking DNS] ************************************************************
changed: [server1.netology]

TASK [Installing tools] ********************************************************
ok: [server1.netology] => (item=git)
ok: [server1.netology] => (item=curl)

TASK [Installing docker] *******************************************************
changed: [server1.netology]

TASK [Add the current user to docker group] ************************************
changed: [server1.netology]

PLAY RECAP *********************************************************************
server1.netology           : ok=7    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

![](img/dz5_2_pic2.png)
