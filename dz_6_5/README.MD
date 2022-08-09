```
cat Dockerfile 
FROM elasticsearch:7.17.5

RUN mkdir /var/lib/elasticsearch/ &amp;&amp; \
        chown -R elasticsearch:elasticsearch /var/lib/elasticsearch/  &amp;&amp; \
        mkdir /usr/share/elasticsearch/snapshots/ &amp;&amp; \
        chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/snapshots/

COPY ./config/elasticsearch.yml /usr/share/elasticsearch/config/

EXPOSE 9200

CMD [&quot;bin/elasticsearch&quot;]

--------------------------
cat docker-compose.yml 
version: '3.1'

services:
  elastic:
    build: .
    restart: always
    ports:
      - 9200:9200

--------------------------

cat ./config/elasticsearch.yml 
# ======================== Elasticsearch Configuration =========================
# ---------------------------------- Cluster -----------------------------------
cluster.name: dz_6_5_netology
# ------------------------------------ Node ------------------------------------
node.name: netology_test
# ----------------------------------- Paths ------------------------------------
path.data: /var/lib/elasticsearch/data
path.logs: /var/lib/elasticsearch/logs
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

=======================

docker build -t maximden/dz_6_5:latest .
docker tag maximden/dz_6_5:latest maximden/dz_6_5:latest
docker login
docker push maximden/dz_6_5:latest
docker run --rm -d --name my_elastic -p 9200:9200 maximden/dz_6_5:latest
=======================

curl http://localhost:9200
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


2. 111
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
====
curl --location --request GET 'localhost:9200/_cat/indices?v=true'

health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases WQUpgnuES2GZRKZjalg8Rg   1   0         39            0       37mb           37mb
green  open   ind-1            tDpXLlQHSOCMdoI-Nbzbeg   1   0          0            0       226b           226b
yellow open   ind-3            ZXbPL0WNSumOKEIL6uE7bw   4   2          0            0       904b           904b
yellow open   ind-2            UF_RjiDYTQ6hOWEzvmNshg   2   1          0            0       452b           452b

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

Часть индексов и кластер находятся в состоянии yellow. Это указывает на присутствие некоторых проблем.
Для кластера недостаточно нод для распределения по ним имеющихся шардов у этих индексов. 
У нас только одна нода, а у индексов 2 и 3 указаны реплики.

Удаление индексов:
curl -X DELETE 'localhost:9200/ind-1'
curl -X DELETE 'localhost:9200/ind-2'
curl -X DELETE 'localhost:9200/ind-3'

url -X GET 'localhost:9200/_cat/indices?v=true'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases WQUpgnuES2GZRKZjalg8Rg   1   0         39            0       37mb           37mb

```