# Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, в который будут складываться данные БД и бэкапы.
Приведите получившуюся команду или docker-compose манифест.  
---
_Ответ:_

Подготавливаем файл `docker-compose.yaml`:
```
version: '2.5'

volumes:
  db_data: {}
  backup: {}

services:

  postgres:
    image: postgres:12
    container_name: postgre_sql
    ports:
      - "0.0.0.0:5432:5432"
    volumes:
      - db_data:/var/lib/postgresql/data
      - backup:/media/pg_backup
    environment:
      POSTGRES_USER: "pg-admin"
      POSTGRES_PASSWORD: "pg-pass"
      POSTGRES_DB: "postgres"
    restart: always
```
Выполняем сборку и запуск контейнера:  
`docker-compose up -d`  
Подключаемся к контейнеру и запускаем консольную утилиту psql в которой выводим список баз данных:  
`docker exec -it postgre_sql psql -U pg-admin postgres`
```
psql (12.11 (Debian 12.11-1.pgdg110+1))
Type "help" for help.

postgres=# \l
                                   List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |     Access privileges     
-----------+----------+----------+------------+------------+---------------------------
 postgres  | pg-admin | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | pg-admin | UTF8     | en_US.utf8 | en_US.utf8 | =c/"pg-admin"            +
           |          |          |            |            | "pg-admin"=CTc/"pg-admin"
 template1 | pg-admin | UTF8     | en_US.utf8 | en_US.utf8 | =c/"pg-admin"            +
           |          |          |            |            | "pg-admin"=CTc/"pg-admin"
(3 rows)
```

---

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
```
postgres=# CREATE DATABASE test_db;
CREATE DATABASE
postgres=# CREATE USER "test-admin-user" WITH PASSWORD 'pass12345';
CREATE ROLE
```
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
```
postgres-# \c test_db
You are now connected to database "test_db" as user "pg-admin".
```
Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)
```
test_db=# CREATE TABLE orders ( id SERIAL PRIMARY KEY, наименование VARCHAR(80), цена INTEGER);
CREATE TABLE
```

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)
```
test_db=# CREATE TABLE clients ( id SERIAL PRIMARY KEY, фамилия VARCHAR(80), "страна проживания" VARCHAR(80), заказ INTEGER, FOREIGN KEY (заказ) REFERENCES orders (id));
CREATE TABLE

test_db=# CREATE INDEX "страна проживания_idx" ON clients ("страна проживания");
CREATE INDEX
```
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
```
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "test-admin-user";
```
- создайте пользователя test-simple-user  
```
CREATE USER "test-simple-user" WITH PASSWORD 'pass123';
```
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
```
test_db=# GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "test-simple-user";
GRANT
```

Приведите:
- итоговый список БД после выполнения пунктов выше,
```
test_db-# \l
                                   List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |     Access privileges     
-----------+----------+----------+------------+------------+---------------------------
 postgres  | pg-admin | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | pg-admin | UTF8     | en_US.utf8 | en_US.utf8 | =c/"pg-admin"            +
           |          |          |            |            | "pg-admin"=CTc/"pg-admin"
 template1 | pg-admin | UTF8     | en_US.utf8 | en_US.utf8 | =c/"pg-admin"            +
           |          |          |            |            | "pg-admin"=CTc/"pg-admin"
 test_db   | pg-admin | UTF8     | en_US.utf8 | en_US.utf8 | 

```
- описание таблиц (describe)
```
test_db-# \dt
          List of relations
 Schema |  Name   | Type  |  Owner   
--------+---------+-------+----------
 public | clients | table | pg-admin
 public | orders  | table | pg-admin
(2 rows)

test_db-# \d clients
                                         Table "public.clients"
      Column       |         Type          | Collation | Nullable |               Default               
-------------------+-----------------------+-----------+----------+-------------------------------------
 id                | integer               |           | not null | nextval('clients_id_seq'::regclass)
 фамилия           | character varying(80) |           |          | 
 страна проживания | character varying(80) |           |          | 
 заказ             | integer               |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "страна проживания_idx" btree ("страна проживания")
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)

test_db-# \d orders
                                      Table "public.orders"
    Column    |         Type          | Collation | Nullable |              Default               
--------------+-----------------------+-----------+----------+------------------------------------
 id           | integer               |           | not null | nextval('orders_id_seq'::regclass)
 наименование | character varying(80) |           |          | 
 цена         | integer               |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)

```
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
```
test_db=# SELECT grantee, table_name, privilege_type 
FROM information_schema.table_privileges 
WHERE grantee in ('test-admin-user','test-simple-user') and table_name in ('clients','orders')
order by 1,2,3;
```
- список пользователей с правами над таблицами test_db
```
     grantee      | table_name | privilege_type 
------------------+------------+----------------
 test-admin-user  | clients    | DELETE
 test-admin-user  | clients    | INSERT
 test-admin-user  | clients    | REFERENCES
 test-admin-user  | clients    | SELECT
 test-admin-user  | clients    | TRIGGER
 test-admin-user  | clients    | TRUNCATE
 test-admin-user  | clients    | UPDATE
 test-admin-user  | orders     | DELETE
 test-admin-user  | orders     | INSERT
 test-admin-user  | orders     | REFERENCES
 test-admin-user  | orders     | SELECT
 test-admin-user  | orders     | TRIGGER
 test-admin-user  | orders     | TRUNCATE
 test-admin-user  | orders     | UPDATE
 test-simple-user | clients    | DELETE
 test-simple-user | clients    | INSERT
 test-simple-user | clients    | SELECT
 test-simple-user | clients    | UPDATE
 test-simple-user | orders     | DELETE
 test-simple-user | orders     | INSERT
 test-simple-user | orders     | SELECT
 test-simple-user | orders     | UPDATE
(22 rows)
```
## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

```
test_db=# INSERT INTO orders VALUES (1, 'Шоколад', 10), (2, 'Принтер', 3000), (3, 'Книга', 500), (4, 'Монитор', 7000), (5, 'Гитара', 4000);
INSERT 0 5
```
Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

```
INSERT INTO clients VALUES (1, 'Иванов Иван Иванович', 'USA'), (2, 'Петров Петр Петрович', 'Canada'), (3, 'Иоганн Себастьян Бах', 'Japan'), (4, 'Ронни Джеймс Дио', 'Russia'), (5, 'Ritchie Blackmore', 'Russia');
INSERT 0 5
```
Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
```
test_db=# SELECT COUNT (*) FROM clients;
 count 
-------
     5
(1 row)

test_db=# SELECT COUNT (*) FROM orders;
 count 
-------
     5
(1 row)

```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.
```
test_db=# UPDATE  clients SET "заказ" = 3 WHERE id = 1;
UPDATE 1
test_db=# UPDATE  clients SET "заказ" = 4 WHERE id = 2;
UPDATE 1
test_db=# UPDATE  clients SET "заказ" = 5 WHERE id = 3;
UPDATE 1
```
Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
```
test_db=# SELECT clients.фамилия,                                 
(SELECT orders.наименование FROM orders WHERE orders.id=clients.заказ) AS заказал FROM clients WHERE clients.заказ is Not Null;
       фамилия        | заказал 
----------------------+---------
 Иванов Иван Иванович | Книга
 Петров Петр Петрович | Монитор
 Иоганн Себастьян Бах | Гитара
(3 rows)

```

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.
```
test_db=# explain SELECT clients.фамилия,
(SELECT orders.наименование FROM orders WHERE orders.id=clients.заказ) AS заказал FROM clients WHERE clients.заказ is Not Null;
                                     QUERY PLAN                                     
------------------------------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..1636.84 rows=199 width=356)
   Filter: ("заказ" IS NOT NULL)
   SubPlan 1
     ->  Index Scan using orders_pkey on orders  (cost=0.15..8.17 rows=1 width=178)
           Index Cond: (id = clients."заказ")
(5 rows)
```
Обозначает то, что сначала будут последовательно просмотрены все строки в таблице `clients` с пирменением фильтра не пустого значения поля заказ, а затем поиск по индексированному полю `id` на соответствие значению `clients."заказ"` 
 ## Задача 6

> Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Создаем резервную копию в Volume для резервной копии.
```
vagrant@vm-docker:~$ docker exec -t postgre_sql pg_dump -U pg-admin test_db -f /media/pg_backup/dump_test_db.sql

vagrant@vm-docker:~$ docker exec -t postgre_sql ls /media/pg_backup
dump_test_db.sql

```
>Остановите контейнер с PostgreSQL (но не удаляйте volumes).  
>Поднимите новый пустой контейнер с PostgreSQL.  
>Восстановите БД test_db в новом контейнере.  
>Приведите список операций, который вы применяли для бэкапа данных и восстановления.  

После создания нового контейнера подключаемся к нему и создаем базу данных и пользователей:
```
postgres=# CREATE DATABASE test_db;
CREATE DATABASE
postgres=# CREATE USER "test-simple-user" WITH PASSWORD 'pass123';
CREATE ROLE
postgres=# CREATE USER "test-admin-user" WITH PASSWORD 'pass12345';
CREATE ROLE
```
После этого запускаем восстановление данных:
```
vagrant@vm-docker:~$ docker exec -it postgre_sql_1 psql -Upg-admin -d test_db -f /media/pg_backup/dump_test_db.sql
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
ALTER TABLE
COPY 5
COPY 5
 setval 
--------
      1
(1 row)

 setval 
--------
      1
(1 row)

ALTER TABLE
ALTER TABLE
CREATE INDEX
ALTER TABLE
GRANT
GRANT
GRANT
GRANT
```

---
