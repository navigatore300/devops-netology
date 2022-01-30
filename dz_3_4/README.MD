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

my_node_env1=param

---
2. Ознакомьтесь с опциями node_exporter и выводом `/metrics` по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.

_Ответ:_  


---
3. Установите в свою виртуальную машину [Netdata](https://github.com/netdata/netdata). Воспользуйтесь [готовыми пакетами](https://packagecloud.io/netdata/netdata/install) для установки (`sudo apt install -y netdata`). После успешной установки:
    * в конфигурационном файле `/etc/netdata/netdata.conf` в секции [web] замените значение с localhost на `bind to = 0.0.0.0`,
    * добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте `vagrant reload`:

    ```bash
    config.vm.network "forwarded_port", guest: 19999, host: 19999
    ```

    После успешной перезагрузки в браузере *на своем ПК* (не в виртуальной машине) вы должны суметь зайти на `localhost:19999`. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata и с комментариями, которые даны к этим метрикам.


_Ответ:_  


---
4. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?

_Ответ:_  


---
5. Как настроен sysctl `fs.nr_open` на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?

_Ответ:_  


---
6. Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`. Для простоты работайте в данном задании под root (`sudo -i`). Под обычным пользователем требуются дополнительные опции (`--map-root-user`) и т.д.

_Ответ:_  


---
7. Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (**это важно, поведение в других ОС не проверялось**). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?

_Ответ:_  


---