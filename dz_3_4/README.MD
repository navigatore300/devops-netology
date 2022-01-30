# Домашнее задание к занятию "3.4. Операционные системы, лекция 2"

1. На лекции мы познакомились с [node_exporter](https://github.com/prometheus/node_exporter/releases). В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой [unit-файл](https://www.freedesktop.org/software/systemd/man/systemd.service.html) для node_exporter:

    * поместите его в автозагрузку,
    * предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на `systemctl cat cron`),
    * удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.
    
_Ответ:_  
Скачал и установил nose_exporter.  
```
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xf node_exporter-1.3.1.linux-amd64.tar.gz
useradd --no-create-home --home-dir / --shell /bin/false node_exporter
cd node_exporter-1.3.1.linux-amd64
chown node_exporter:node_exporter node_exporter
cp node_exporter /usr/local/bin/
```
Создал файл /etc/systemd/system/node_exporter.service:
```
Description=Prometheus Node Exporter
After=network.target

[Service]
Type=simple
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter

EnvironmentFile=-/etc/node_exporter/node_env.cfg

SyslogIdentifier=node_exporter
Restart=always

PrivateTmp=yes
ProtectHome=yes
NoNewPrivileges=yes

ProtectSystem=strict
ProtectControlGroups=true
ProtectKernelModules=true
ProtectKernelTunables=yes

[Install]
WantedBy=multi-user.target
```
Запусти и проверил работу:
```
systemctl daemon-reload
systemctl start node_exporter

root@vagrant:~# systemctl status node_exporter
● node_exporter.service - Prometheus Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2022-01-30 09:32:36 UTC; 35s ago
   Main PID: 1841 (node_exporter)
      Tasks: 5 (limit: 1071)
     Memory: 2.5M
     CGroup: /system.slice/node_exporter.service
             └─1841 /usr/local/bin/node_exporter

Jan 30 09:32:36 vagrant node_exporter[1841]: ts=2022-01-30T09:32:36.356Z caller=node_exporter.go:115 level=info collector=thermal_zone
Jan 30 09:32:36 vagrant node_exporter[1841]: ts=2022-01-30T09:32:36.356Z caller=node_exporter.go:115 level=info collector=time
Jan 30 09:32:36 vagrant node_exporter[1841]: ts=2022-01-30T09:32:36.356Z caller=node_exporter.go:115 level=info collector=timex
Jan 30 09:32:36 vagrant node_exporter[1841]: ts=2022-01-30T09:32:36.356Z caller=node_exporter.go:115 level=info collector=udp_queues
Jan 30 09:32:36 vagrant node_exporter[1841]: ts=2022-01-30T09:32:36.356Z caller=node_exporter.go:115 level=info collector=uname
Jan 30 09:32:36 vagrant node_exporter[1841]: ts=2022-01-30T09:32:36.356Z caller=node_exporter.go:115 level=info collector=vmstat
Jan 30 09:32:36 vagrant node_exporter[1841]: ts=2022-01-30T09:32:36.356Z caller=node_exporter.go:115 level=info collector=xfs
Jan 30 09:32:36 vagrant node_exporter[1841]: ts=2022-01-30T09:32:36.356Z caller=node_exporter.go:115 level=info collector=zfs
Jan 30 09:32:36 vagrant node_exporter[1841]: ts=2022-01-30T09:32:36.356Z caller=node_exporter.go:199 level=info msg="Listening on" address=:9100
Jan 30 09:32:36 vagrant node_exporter[1841]: ts=2022-01-30T09:32:36.357Z caller=tls_config.go:195 level=info msg="TLS is disabled." http2=false

root@vagrant:~# systemctl status node_exporter
root@vagrant:~# curl -s http://localhost:9100/metrics
# HELP go_gc_duration_seconds A summary of the pause duration of garbage collection cycles.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 0
go_gc_duration_seconds{quantile="0.25"} 0
go_gc_duration_seconds{quantile="0.5"} 0
go_gc_duration_seconds{quantile="0.75"} 0
go_gc_duration_seconds{quantile="1"} 0
go_gc_duration_seconds_sum 0
go_gc_duration_seconds_count 0
# HELP go_goroutines Number of goroutines that currently exist.
# TYPE go_goroutines gauge
go_goroutines 8
# HELP go_info Information about the Go environment.
# TYPE go_info gauge
go_info{version="go1.17.3"} 1
# HELP go_memstats_alloc_bytes Number of bytes allocated and still in use.
# TYPE go_memstats_alloc_bytes gauge
go_memstats_alloc_bytes 1.387e+06
# HELP go_memstats_alloc_bytes_total Total number of bytes allocated, even if freed.
# TYPE go_memstats_alloc_bytes_total counter
go_memstats_alloc_bytes_total 1.387e+06
# HELP go_memstats_buck_hash_sys_bytes Number of bytes used by the profiling bucket hash table.
# TYPE go_memstats_buck_hash_sys_bytes gauge
go_memstats_buck_hash_sys_bytes 1.445359e+06
...
```


Включил автозагрузку:
```
systemctl enable node_exporter
```
Процесс стартует, останавливается корректно. Автозагрузка работает.  
``` 
root@vagrant:~# systemctl stop node_exporteriron
root@vagrant:~# systemctl status node_exporter
● node_exporter.service - Prometheus Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: inactive (dead) since Sun 2022-01-30 09:54:17 UTC; 6s ago
    Process: 1986 ExecStart=/usr/local/bin/node_exporter (code=killed, signal=TERM)
   Main PID: 1986 (code=killed, signal=TERM)

Jan 30 09:47:18 vagrant node_exporter[1986]: ts=2022-01-30T09:47:18.677Z caller=node_exporter.go:115 level=info collector=udp_queues
Jan 30 09:47:18 vagrant node_exporter[1986]: ts=2022-01-30T09:47:18.677Z caller=node_exporter.go:115 level=info collector=uname
Jan 30 09:47:18 vagrant node_exporter[1986]: ts=2022-01-30T09:47:18.677Z caller=node_exporter.go:115 level=info collector=vmstat
Jan 30 09:47:18 vagrant node_exporter[1986]: ts=2022-01-30T09:47:18.677Z caller=node_exporter.go:115 level=info collector=xfs
Jan 30 09:47:18 vagrant node_exporter[1986]: ts=2022-01-30T09:47:18.677Z caller=node_exporter.go:115 level=info collector=zfs
Jan 30 09:47:18 vagrant node_exporter[1986]: ts=2022-01-30T09:47:18.677Z caller=node_exporter.go:199 level=info msg="Listening on" address=:9100
Jan 30 09:47:18 vagrant node_exporter[1986]: ts=2022-01-30T09:47:18.677Z caller=tls_config.go:195 level=info msg="TLS is disabled." http2=false
Jan 30 09:54:17 vagrant systemd[1]: Stopping Prometheus Node Exporter...
Jan 30 09:54:17 vagrant systemd[1]: node_exporter.service: Succeeded.
Jan 30 09:54:17 vagrant systemd[1]: Stopped Prometheus Node Exporter.
```
В unit-файл добавлена строка  
>EnvironmentFile=/etc/node_exporter/node_env.cfg

для возможности добавления опций к запускаемому процессу через внешний файл /etc/node_exporter/node_env.cfg  

```
ps aux | grep node
node_ex+    1986  0.6  1.1 715964 11440 ?        Ssl  09:47   0:00 /usr/local/bin/node_exporter
root        2002  0.0  0.0   6300   740 pts/0    S+   09:47   0:00 grep --color=auto node
root@vagrant:~# cat /proc/1986/environ
```
>LANG=en_US.UTF-8PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/binLOGNAME=node_exporterUSER=node_exporterINVOCATION_ID=05c8edc57eee457790ba106dfd4541edJOURNAL_STREAM=9:31523my_node_env1=param

 В окружении процесса можно видеть добавленную переменную из файла _my_node_env1=param_

---

2. Ознакомьтесь с опциями node_exporter и выводом `/metrics` по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.

_Ответ:_  
Для процессора:
```
# HELP node_cpu_seconds_total Seconds the CPUs spent in each mode.
# TYPE node_cpu_seconds_total counter
node_cpu_seconds_total{cpu="0",mode="idle"} 8097.5
node_cpu_seconds_total{cpu="0",mode="iowait"} 2
node_cpu_seconds_total{cpu="0",mode="irq"} 0
node_cpu_seconds_total{cpu="0",mode="nice"} 0
node_cpu_seconds_total{cpu="0",mode="softirq"} 1.86
node_cpu_seconds_total{cpu="0",mode="steal"} 0
node_cpu_seconds_total{cpu="0",mode="system"} 10.89
node_cpu_seconds_total{cpu="0",mode="user"} 14.36
node_cpu_seconds_total{cpu="1",mode="idle"} 8103.97
node_cpu_seconds_total{cpu="1",mode="iowait"} 0.95
node_cpu_seconds_total{cpu="1",mode="irq"} 0
node_cpu_seconds_total{cpu="1",mode="nice"} 0
node_cpu_seconds_total{cpu="1",mode="softirq"} 0.64
node_cpu_seconds_total{cpu="1",mode="steal"} 0
node_cpu_seconds_total{cpu="1",mode="system"} 8.96
node_cpu_seconds_total{cpu="1",mode="user"} 10.78
```
Для дисков:
```
# HELP node_disk_info Info of /sys/block/<block_device>.
# TYPE node_disk_info gauge
node_disk_info{device="dm-0",major="253",minor="0"} 1
node_disk_info{device="sda",major="8",minor="0"} 1
# HELP node_disk_io_now The number of I/Os currently in progress.
# TYPE node_disk_io_now gauge
node_disk_io_now{device="dm-0"} 0
node_disk_io_now{device="sda"} 0
# HELP node_disk_io_time_seconds_total Total seconds spent doing I/Os.
# TYPE node_disk_io_time_seconds_total counter
node_disk_io_time_seconds_total{device="dm-0"} 10
node_disk_io_time_seconds_total{device="sda"} 10.24
# HELP node_disk_io_time_weighted_seconds_total The weighted # of seconds spent doing I/Os.
# TYPE node_disk_io_time_weighted_seconds_total counter
node_disk_io_time_weighted_seconds_total{device="dm-0"} 12.008000000000001
node_disk_io_time_weighted_seconds_total{device="sda"} 1.364
# HELP node_disk_read_bytes_total The total number of bytes read successfully.
# TYPE node_disk_read_bytes_total counter
node_disk_read_bytes_total{device="dm-0"} 3.68944128e+08
node_disk_read_bytes_total{device="sda"} 3.784192e+08
# HELP node_disk_read_time_seconds_total The total number of seconds spent by all reads.
# TYPE node_disk_read_time_seconds_total counter
node_disk_read_time_seconds_total{device="dm-0"} 7.792
node_disk_read_time_seconds_total{device="sda"} 5.1530000000000005
# HELP node_disk_reads_completed_total The total number of reads completed successfully.
# TYPE node_disk_reads_completed_total counter
node_disk_reads_completed_total{device="dm-0"} 11134
node_disk_reads_completed_total{device="sda"} 8758
# HELP node_disk_reads_merged_total The total number of reads merged.
# TYPE node_disk_reads_merged_total counter
node_disk_reads_merged_total{device="dm-0"} 0
node_disk_reads_merged_total{device="sda"} 2689
# HELP node_disk_write_time_seconds_total This is the total number of seconds spent by all writes.
# TYPE node_disk_write_time_seconds_total counter
node_disk_write_time_seconds_total{device="dm-0"} 4.216
node_disk_write_time_seconds_total{device="sda"} 4.174
# HELP node_disk_writes_completed_total The total number of writes completed successfully.
# TYPE node_disk_writes_completed_total counter
node_disk_writes_completed_total{device="dm-0"} 8700
node_disk_writes_completed_total{device="sda"} 5114
# HELP node_disk_writes_merged_total The number of writes merged.
# TYPE node_disk_writes_merged_total counter
node_disk_writes_merged_total{device="dm-0"} 0
node_disk_writes_merged_total{device="sda"} 3651
# HELP node_disk_written_bytes_total The total number of bytes written successfully.
# TYPE node_disk_written_bytes_total counter
node_disk_written_bytes_total{device="dm-0"} 9.2606464e+07
node_disk_written_bytes_total{device="sda"} 9.1557888e+07
```
Для памяти:
```
# HELP node_memory_MemAvailable_bytes Memory information field MemAvailable_bytes.
# TYPE node_memory_MemAvailable_bytes gauge
node_memory_MemAvailable_bytes 7.1266304e+08
# HELP node_memory_MemFree_bytes Memory information field MemFree_bytes.
# TYPE node_memory_MemFree_bytes gauge
node_memory_MemFree_bytes 3.46230784e+08
```
Для сетевых интерфейсов:
```
# HELP node_network_address_assign_type address_assign_type value of /sys/class/net/<iface>.
# TYPE node_network_address_assign_type gauge
node_network_address_assign_type{device="eth0"} 0
node_network_address_assign_type{device="eth1"} 0
node_network_address_assign_type{device="lo"} 0
# HELP node_network_carrier carrier value of /sys/class/net/<iface>.
# TYPE node_network_carrier gauge
node_network_carrier{device="eth0"} 1
node_network_carrier{device="eth1"} 1
node_network_carrier{device="lo"} 1
# HELP node_network_info Non-numeric data from /sys/class/net/<iface>, value is always 1.
# TYPE node_network_info gauge
node_network_info{address="00:00:00:00:00:00",broadcast="00:00:00:00:00:00",device="lo",duplex="",ifalias="",operstate="unknown"} 1
node_network_info{address="08:00:27:9b:b1:41",broadcast="ff:ff:ff:ff:ff:ff",device="eth1",duplex="full",ifalias="",operstate="up"} 1
node_network_info{address="08:00:27:b1:28:5d",broadcast="ff:ff:ff:ff:ff:ff",device="eth0",duplex="full",ifalias="",operstate="up"} 1
# HELP node_network_mtu_bytes mtu_bytes value of /sys/class/net/<iface>.
# TYPE node_network_mtu_bytes gauge
node_network_mtu_bytes{device="eth0"} 1500
node_network_mtu_bytes{device="eth1"} 1500
node_network_mtu_bytes{device="lo"} 65536
# HELP node_network_receive_bytes_total Network device statistic receive_bytes.
# TYPE node_network_receive_bytes_total counter
node_network_receive_bytes_total{device="eth0"} 2.725278e+06
node_network_receive_bytes_total{device="eth1"} 3273
node_network_receive_bytes_total{device="lo"} 186220
# HELP node_network_receive_drop_total Network device statistic receive_drop.
# TYPE node_network_receive_drop_total counter
node_network_receive_drop_total{device="eth0"} 0
node_network_receive_drop_total{device="eth1"} 0
node_network_receive_drop_total{device="lo"} 0
# HELP node_network_receive_errs_total Network device statistic receive_errs.
# TYPE node_network_receive_errs_total counter
node_network_receive_errs_total{device="eth0"} 0
node_network_receive_errs_total{device="eth1"} 0
node_network_receive_errs_total{device="lo"} 0
# HELP node_network_receive_packets_total Network device statistic receive_packets.
# TYPE node_network_receive_packets_total counter
node_network_receive_packets_total{device="eth0"} 10334
node_network_receive_packets_total{device="eth1"} 21
node_network_receive_packets_total{device="lo"} 125
# HELP node_network_speed_bytes speed_bytes value of /sys/class/net/<iface>.
# TYPE node_network_speed_bytes gauge
node_network_speed_bytes{device="eth0"} 1.25e+08
node_network_speed_bytes{device="eth1"} 1.25e+08
# HELP node_network_transmit_bytes_total Network device statistic transmit_bytes.
# TYPE node_network_transmit_bytes_total counter
node_network_transmit_bytes_total{device="eth0"} 685449
node_network_transmit_bytes_total{device="eth1"} 1956
node_network_transmit_bytes_total{device="lo"} 186220
# HELP node_network_transmit_drop_total Network device statistic transmit_drop.
# TYPE node_network_transmit_drop_total counter
node_network_transmit_drop_total{device="eth0"} 0
node_network_transmit_drop_total{device="eth1"} 0
node_network_transmit_drop_total{device="lo"} 0
# HELP node_network_transmit_errs_total Network device statistic transmit_errs.
# TYPE node_network_transmit_errs_total counter
node_network_transmit_errs_total{device="eth0"} 0
node_network_transmit_errs_total{device="eth1"} 0
node_network_transmit_errs_total{device="lo"} 0
# HELP node_network_transmit_packets_total Network device statistic transmit_packets.
# TYPE node_network_transmit_packets_total counter
node_network_transmit_packets_total{device="eth0"} 6840
node_network_transmit_packets_total{device="eth1"} 26
node_network_transmit_packets_total{device="lo"} 125
# HELP node_network_up Value is 1 if operstate is 'up', 0 otherwise.
# TYPE node_network_up gauge
node_network_up{device="eth0"} 1
node_network_up{device="eth1"} 1
node_network_up{device="lo"} 0

```

---

3. Установите в свою виртуальную машину [Netdata](https://github.com/netdata/netdata). Воспользуйтесь [готовыми пакетами](https://packagecloud.io/netdata/netdata/install) для установки (`sudo apt install -y netdata`). После успешной установки:
    * в конфигурационном файле `/etc/netdata/netdata.conf` в секции [web] замените значение с localhost на `bind to = 0.0.0.0`,
    * добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте `vagrant reload`:

    ```bash
    config.vm.network "forwarded_port", guest: 19999, host: 19999
    ```

    После успешной перезагрузки в браузере *на своем ПК* (не в виртуальной машине) вы должны суметь зайти на `localhost:19999`. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.


_Ответ:_  

Задание выполнено:
>vagrant@vagrant:~$ sudo lsof -i :19999  
COMMAND PID    USER   FD   TYPE DEVICE SIZE/OFF NODE NAME  
netdata 643 netdata    4u  IPv4  23044      0t0  TCP *:19999 (LISTEN)  
netdata 643 netdata   23u  IPv4  33164      0t0  TCP vagrant:19999->_gateway:1690 (ESTABLISHED)  


![](img/pic1.png)

---

4. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?

_Ответ:_  

Да. В логах она так и пишет, что определена виртуализация.
```bash
vagrant@vagrant:~$ dmesg | grep virtu
[    0.004629] CPU MTRRs all blank - virtualized system.
[    0.173834] Booting paravirtualized kernel on KVM
[    3.523541] systemd[1]: Detected virtualization oracle.
```

---
5. Как настроен sysctl `fs.nr_open` на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?

_Ответ:_  

Текущее значение параметра можно просмотреть командой
```bash
vagrant@vagrant:~$ sudo sysctl -a | grep fs.nr_open
fs.nr_open = 1048576
```
nr_open - это максимальное количество файловых дескрипторов, которые может использовать процесс.
Число задается кратное 1024, в данном случае =1024*1024.

Максимальный предел для ОС можно посмотреть так:
```bash
vagrant@vagrant:~$ cat /proc/sys/fs/file-max
9223372036854775807
```
Достичь числа указанного в `fs.nr_open` не позволит мягкое ограничение максимального числа дескрипторов открытых файлов `ulimit -Sn`. В свою очередь мягкое ограничение хотя и может быть увеличено, но оно не может превышать жесткое ограничение `ulimit -Hn`.
```bash
vagrant@vagrant:~$ ulimit -Sn
1024
vagrant@vagrant:~$ ulimit -Hn
1048576
```
В свою очередь оба этих лимита не могут превышать размер параметра `fs.nr_open`

---

6. Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`. Для простоты работайте в данном задании под root (`sudo -i`). Под обычным пользователем требуются дополнительные опции (`--map-root-user`) и т.д.

_Ответ:_  


---
7. Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (**это важно, поведение в других ОС не проверялось**). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?

_Ответ:_  


---