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
      POSTGRES_USER: "pg-user"
      POSTGRES_PASSWORD: "pg-pass"
      POSTGRES_DB: "test_db"
    restart: always
```
Выполняем сборку и запуск контейнера:  
`docker-compose up -d`  
Подключаемся к контейнеру и запускаем консольную утилиту psql в которой выводим список баз данных:  
`docker exec -it postgre_sql psql -U pg-user test_db`
```
psql (12.11 (Debian 12.11-1.pgdg110+1))
Type "help" for help.

test_db=# \l
                                 List of databases
   Name    |  Owner  | Encoding |  Collate   |   Ctype    |    Access privileges    
-----------+---------+----------+------------+------------+-------------------------
 postgres  | pg-user | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | pg-user | UTF8     | en_US.utf8 | en_US.utf8 | =c/"pg-user"           +
           |         |          |            |            | "pg-user"=CTc/"pg-user"
 template1 | pg-user | UTF8     | en_US.utf8 | en_US.utf8 | =c/"pg-user"           +
           |         |          |            |            | "pg-user"=CTc/"pg-user"
 test_db   | pg-user | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)

test_db=# 
```

---

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

test_db=# CREATE TABLE orders ( id SERIAL PRIMARY KEY, наименование VARCHAR(80), цена INTEGER);
CREATE TABLE
test_db=# \d orders
                                      Table "public.orders"
    Column    |         Type          | Collation | Nullable |              Default               
--------------+-----------------------+-----------+----------+------------------------------------
 id           | integer               |           | not null | nextval('orders_id_seq'::regclass)
 наименование | character varying(80) |           |          | 
 цена         | integer               |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)


Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

test_db=# CREATE TABLE clients ( id SERIAL PRIMARY KEY, фамилия VARCHAR(80), "страна проживания" VARCHAR(80), заказ INTEGER, FOREIGN KEY (заказ) REFERENCES orders (id));
CREATE TABLE

test_db=# CREATE INDEX "страна проживания_idx" ON clients ("страна проживания");
CREATE INDEX

test_db=# \d clients
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



Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

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

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

---
