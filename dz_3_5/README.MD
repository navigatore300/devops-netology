1. Узнайте о sparse (разряженных) файлах.

_Ответ_

Разрежённый файл (англ. sparse file) — файл, в котором последовательности нулевых байтов заменены на информацию об этих последовательностях (список дыр)  

Преимущества:

+ экономия дискового пространства. Использование разрежённых файлов считается одним из способов сжатия данных на уровне файловой системы;
+ отсутствие временных затрат на запись нулевых байт;
+ увеличение срока службы запоминающих устройств.

Недостатки:

+ накладные расходы на работу со списком дыр;
+ фрагментация файла при частой записи данных в дыры;
+ невозможность записи данных в дыры при отсутствии свободного места на диске;
+ невозможность использования других индикаторов дыр, кроме нулевых байт.

---

2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

_Ответ_

Так как жесткая ссылка это ссылка на тот же самый файл и имеет тот же inode то права будут одни и те же.
Так как права на доступ хранятся в таблице inode.

---

3. Сделайте vagrant destroy на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.provider :virtualbox do |vb|
    lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
    lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
    vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
    vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
  end
end
Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

_Ответ_


![](img/pic1.png)

---

4. Используя fdisk, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

_Ответ_

```bash
root@vagrant:~# fdisk /dev/sdb

Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x5ae0dd95.

Command (m for help): i
No partition is defined yet!

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (1-4, default 1):
First sector (2048-5242879, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (2-4, default 2):
First sector (4196352-5242879, default 4196352):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879):

Created a new partition 2 of type 'Linux' and of size 511 MiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

---

5. Используя sfdisk, перенесите данную таблицу разделов на второй диск.


_Ответ_

```bash
root@vagrant:~# sfdisk -d /dev/sdb > sdb-tables.dump
root@vagrant:~# cat sdb-tables.dump
label: dos
label-id: 0x5ae0dd95
device: /dev/sdb
unit: sectors

/dev/sdb1 : start=        2048, size=     4194304, type=83
/dev/sdb2 : start=     4196352, size=     1046528, type=83

root@vagrant:~# sfdisk /dev/sdc < sdb-tables.dump
Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new DOS disklabel with disk identifier 0x5ae0dd95.
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 511 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0x5ae0dd95

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

---

6. Соберите mdadm RAID1 на паре разделов 2 Гб.

_Ответ_
```
root@vagrant:~# mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sd[bc]1
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```

---

7. Соберите mdadm RAID0 на второй паре маленьких разделов.

_Ответ_
```bash
root@vagrant:~# mdadm --create /dev/md1 --level=0 --raid-devices=2 /dev/sd[bc]2
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
```


---

8. Создайте 2 независимых PV на получившихся md-устройствах.

_Ответ_



---

9. Создайте общую volume-group на этих двух PV.

_Ответ_



---

10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

_Ответ_



---

11. Создайте mkfs.ext4 ФС на получившемся LV.

_Ответ_



---

12. Смонтируйте этот раздел в любую директорию, например, /tmp/new.

_Ответ_



---

13. Поместите туда тестовый файл, например wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz.

_Ответ_



---

14. Прикрепите вывод lsblk.

_Ответ_



---

15. Протестируйте целостность файла:

root@vagrant:~# gzip -t /tmp/new/test.gz
root@vagrant:~# echo $?
0

_Ответ_



---

16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

_Ответ_



---

17. Сделайте --fail на устройство в вашем RAID1 md.

_Ответ_



---

18. Подтвердите выводом dmesg, что RAID1 работает в деградированном состоянии.

_Ответ_



---

19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

root@vagrant:~# gzip -t /tmp/new/test.gz
root@vagrant:~# echo $?
0

_Ответ_



---

20. Погасите тестовый хост, vagrant destroy.

_Ответ_



---
