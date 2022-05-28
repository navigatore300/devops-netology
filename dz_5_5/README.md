# Домашнее задание к занятию "5.5. Оркестрация кластером Docker контейнеров на примере Docker Swarm"

## Задача 1

Дайте письменые ответы на следующие вопросы:

- В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?
- Какой алгоритм выбора лидера используется в Docker Swarm кластере?
- Что такое Overlay Network?

---
_Ответ:_
> - В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?

В режиме `replicated` приложение запускается в том количестве экземпляров, какое укажет пользователь. При этом на отдельной ноде может быть как несколько экземпляров приложения, так и не быть совсем.  
В режиме `global` приложение запускается обязательно на каждой ноде и в единственном экземпляре. 
 
>- Какой алгоритм выбора лидера используется в Docker Swarm кластере?

Используется алгоритм Raft.

Протокол решает проблему согласованности: чтобы все manager ноды имели одинаковое представление о состоянии кластера
Для отказоустойчивой работы должно быть не менее трёх manager нод.  
Количество нод обязательно должно быть нечётным, но лучше не более 7 (это рекомендация из документации Docker).  
Среди manager нод выбирается лидер, его задача гарантировать согласованность.  
Лидер отправляет keepalive пакеты с заданной периодичностью в пределах 150-300мс. Если пакеты не пришли, менеджеры начинают выборы нового лидера.  
Если кластер разбит, нечётное количество нод должно гарантировать, что кластер останется консистентным, т.к. факт изменения состояния считается совершенным, если его отразило большинство нод. Если разбить кластер пополам, нечётное число гарантирует что в какой-то части кластера будеть большинство нод.  

> - Что такое Overlay Network?

Сетевой overlay драйвер создает распределенную сеть между несколькими узлами демона Docker. Эта сеть находится поверх (перекрывает) сети, специфичные для хоста, позволяя контейнерам, подключенным к ней (включая контейнеры службы swarm), безопасно обмениваться данными при включенном шифровании. Docker прозрачно обрабатывает маршрутизацию каждого пакета от и к правильному хосту демона Docker и правильному контейнеру назначения.

---
## Задача 2

Создать ваш первый Docker Swarm кластер в Яндекс. Облаке

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker node ls
```
_Ответ:_  
```
[root@node01 ~]# docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
0i6xxhycyktsjzjxev98ao26w *   node01.netology.yc   Ready     Active         Leader           20.10.16
jlv0tjj19hbe5qrkaicl471bb     node02.netology.yc   Ready     Active         Reachable        20.10.16
wucutxybytv0t1livdh5i5qaq     node03.netology.yc   Ready     Active         Reachable        20.10.16
5npler0o2stxts9y99x0xvx55     node04.netology.yc   Ready     Active                          20.10.16
d6qbrkpmsu5af7cqk3k9jb5s3     node05.netology.yc   Ready     Active                          20.10.16
epdhmef99koe53hsymykos196     node06.netology.yc   Ready     Active                          20.10.16
```
## Задача 3

Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker service ls
```
_Ответ:_  
```
[root@node01 ~]# docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
k14ct3w1oygp   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0    
wmre29fcdi8y   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
gtgzxxgdaz2v   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest                         
brdi251okguj   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest                      
zllmwo805fnz   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4           
wtncgwn838kd   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0   
g4i5r1pdaoam   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0       
6y10ss1risj0   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0            
```
## Задача 4 (*)

Выполнить на лидере Docker Swarm кластера команду (указанную ниже) и дать письменное описание её функционала, что она делает и зачем она нужна:
```
# см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/
docker swarm update --autolock=true
```
_Ответ:_  
```
[root@node02 ~]# docker swarm update --autolock=true
Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-ErjvyS67N50JuslMRr8lR+dgjz9dKkLO/d5B+ApBTdE

Please remember to store this key in a password manager, since without it you
will not be able to restart the manager.
```
Данная комманда включает режим работы кластера с автоблокировкой, то есть после разрыва связи с кластером нода не сможет автоматически вернутся и получить все ключи для работы в кластере. Для возвращения или добавления нового узла нужно будет предьявить ключь, выданный при включении данного режима. Для этого необходимо на подключаемом узле ввести команду `docker swarm unlock`.  
```
root@node01 ~]# docker swarm unlock
Please enter unlock key: 
```