# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.  

---
_Ответ:_  
Создаем папку config в которой размещаем файл elasticsearch.yml следующего содержания:  
```shell
# ======================== Elasticsearch Configuration =========================
# ---------------------------------- Cluster -----------------------------------
cluster.name: dz_6_5_netology
# ------------------------------------ Node ------------------------------------
node.name: netology_test
# ----------------------------------- Paths ------------------------------------
path.data: /var/lib/elasticsearch/data
path.logs: /var/lib/elasticsearch/logs
# Folder for task 3. Snapshots.
path.repo: /usr/share/elasticsearch/snapshots
# ----------------------------------- Memory -----------------------------------
#
# ---------------------------------- Network -----------------------------------
network.host: 0.0.0.0
# --------------------------------- Discovery ----------------------------------
discovery.type: single-node
# --------------------------------- Readiness ----------------------------------
#readiness.port: 9399
# ---------------------------------- Various -----------------------------------
#action.destructive_requires_name: false
xpack.ml.enabled: false
```
Подготавливаем Dockerfile для контейнера:  
```
FROM elasticsearch:7.17.5

RUN mkdir /var/lib/elasticsearch/ &amp;&amp; \
        chown -R elasticsearch:elasticsearch /var/lib/elasticsearch/  &amp;&amp; \
        mkdir /usr/share/elasticsearch/snapshots/ &amp;&amp; \
        chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/snapshots/

COPY ./config/elasticsearch.yml /usr/share/elasticsearch/config/

EXPOSE 9200

CMD ["bin/elasticsearch"]
```
Строим контейнер:  

`docker build -t maximden/dz_6_5:latest .`  

Навешиваем тег и push-им его в docker hub.
```
docker tag maximden/dz_6_5:latest maximden/dz_6_5:latest
docker login
docker push maximden/dz_6_5:latest
```
Запускаем постоеный контейнер:  

`docker run --rm -d --name my_elastic -p 9200:9200 maximden/dz_6_5:latest`

Ответ `elasticsearch` на запрос пути `/` в json виде:  

`curl http://localhost:9200`  
```
{
  "name" : "netology_test",
  "cluster_name" : "dz_6_5_netology",
  "cluster_uuid" : "nbjXfWu_QU2WdcaLlWm_eA",
  "version" : {
    "number" : "7.17.5",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "8d61b4f7ddf931f219e3745f295ed2bbc50c8e84",
    "build_date" : "2022-06-23T21:57:28.736740635Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

Ссылка на репозиторий https://hub.docker.com/r/maximden/dz_6_5


## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

---
_Ответ:_  

Добавим в `elasticsearch` 3 индекса в  соответствии с таблицей:  
```
curl -X PUT "localhost:9200/ind-1" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_replicas": 0,
    "number_of_shards": 1
  }
}
'
---
curl -X PUT "localhost:9200/ind-2" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_replicas": 1,
    "number_of_shards": 2
  }
}
'
---
curl -X PUT "localhost:9200/ind-3" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_replicas": 2,
    "number_of_shards": 4
  }
}
'
```
Получим список индексов и их статусы, используя API:  
```
curl --location --request GET 'localhost:9200/_cat/indices?v=true'

health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases WQUpgnuES2GZRKZjalg8Rg   1   0         39            0       37mb           37mb
green  open   ind-1            tDpXLlQHSOCMdoI-Nbzbeg   1   0          0            0       226b           226b
yellow open   ind-3            ZXbPL0WNSumOKEIL6uE7bw   4   2          0            0       904b           904b
yellow open   ind-2            UF_RjiDYTQ6hOWEzvmNshg   2   1          0            0       452b           452b
``` 
Получим состояние кластера elasticsearch, используя API:  
```
curl localhost:9200/_cluster/health | python3 -m json.tool

{
    "cluster_name": "dz_6_5_netology",
    "status": "yellow",
    "timed_out": false,
    "number_of_nodes": 1,
    "number_of_data_nodes": 1,
    "active_primary_shards": 10,
    "active_shards": 10,
    "relocating_shards": 0,
    "initializing_shards": 0,
    "unassigned_shards": 10,
    "delayed_unassigned_shards": 0,
    "number_of_pending_tasks": 0,
    "number_of_in_flight_fetch": 0,
    "task_max_waiting_in_queue_millis": 0,
    "active_shards_percent_as_number": 50.0
}
``` 
Часть индексов и кластер находятся в состоянии yellow. Это указывает на присутствие некоторых проблем.
Для кластера недостаточно нод для распределения по ним имеющихся шардов для индексов со значением реплик более нуля. 
У нас только одна нода, а у индексов 2 и 3 указаны реплики.

Удаление индексов:  
```
curl -X DELETE 'localhost:9200/ind-1'
curl -X DELETE 'localhost:9200/ind-2'
curl -X DELETE 'localhost:9200/ind-3'
```
Результат после удаления:  
```
сurl -X GET 'localhost:9200/_cat/indices?v=true'

health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases WQUpgnuES2GZRKZjalg8Rg   1   0         39            0       37mb           37mb
```
## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

_Ответ:_

Регистрация репозитория:
```shell
curl -X PUT "localhost:9200/_snapshot/netology_backup" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/snapshots"
  }
}'
```
В ответ получаем: `{"acknowledged":true}`  

Создаем индекс test с 0 реплик и 1 шардом:
```
curl -X PUT "localhost:9200/test" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_replicas": 0,
      "number_of_shards": 1
    }  
  }
}
'
```

Получаем в ответ: `{"acknowledged":true,"shards_acknowledged":true,"index":"test"}`  
Просматриваем список индексов:  
```
сurl -X GET 'localhost:9200/_cat/indices?v=true'

health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases WQUpgnuES2GZRKZjalg8Rg   1   0         39            0       37mb           37mb
green  open   test             _Qu7Uw7JSiiGjNNO9D8nxA   1   0          0            0       226b           226b
```

Создаем snapshot состояния кластера elasticsearch:

`curl -X PUT 'localhost:9200/_snapshot/netology_backup/first_snapshot'`  

Получаем в ответ:  

`{"accepted":true}`

Просмотрим список файлов в директории со snapshot-ами:  
```shell
docker exec -t 1c414d4510ec ls /usr/share/elasticsearch/snapshots/ -lah 

total 52K
drwxr-xr-x 1 elasticsearch elasticsearch 4.0K Aug  9 17:38 .
drwxrwxr-x 1 root          root          4.0K Aug  9 10:20 ..
-rw-rw-r-- 1 elasticsearch root          1.4K Aug  9 17:38 index-0
-rw-rw-r-- 1 elasticsearch root             8 Aug  9 17:38 index.latest
drwxrwxr-x 6 elasticsearch root          4.0K Aug  9 17:38 indices
-rw-rw-r-- 1 elasticsearch root           23K Aug  9 17:38 meta-daRW2SKvRO6DCB3ITi_fnA.dat
-rw-rw-r-- 1 elasticsearch root           713 Aug  9 17:38 snap-daRW2SKvRO6DCB3ITi_fnA.dat
```

Результирующий список индексов после удаления test и создания test-2:
```shell
curl -X GET 'localhost:9200/_cat/indices?v=true'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases WQUpgnuES2GZRKZjalg8Rg   1   0         39            0       37mb           37mb
green  open   test-2           nEUAHIrRRum5jkwpDgXEzQ   1   0          0            0       226b           226b
```
Восстановление из snapshot-а. Явно указываем индекс test для восстановления, так как восстановление без аргументов приводило к ошибке из-за того, что дефолтный индекс .geoip_databases уже существовал:  
```shell
curl -X POST 'localhost:9200/_snapshot/netology_backup/first_snapshot/_restore' \
-H 'Content-Type: application/json' \
-d '{
    "indices": "test"
}'
```
Список индексов после восстановления:
```shell
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases WQUpgnuES2GZRKZjalg8Rg   1   0         39            0       37mb           37mb
green  open   test-2           nEUAHIrRRum5jkwpDgXEzQ   1   0          0            0       226b           226b
green  open   test             kGguRorXRU6f9JyXk6s0ng   1   0          0            0       226b           226b
```
