## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.  
Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.  
Перейдите в управляющую консоль `mysql` внутри контейнера.  
Используя команду `\h` получите список управляющих команд.  
Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.  
Подключитесь к восстановленной БД и получите список таблиц из этой БД.  
**Приведите в ответе** количество записей с `price` > 300.  
В следующих заданиях мы будем продолжать работу с данным контейнером.   


---
_Ответ:_  

Создадим хранилище где будет находится БД.
```
vagrant@vm-docker:~/mysql$ docker volume create mysql_volume
mysql_volume
```
подготовим каталог где будет файл с бекапом из которого будем восстанавливать данные.
```
mkdir backup
nano $PWD\backup\backup.sql
```
вставляем в него данные.  
Запускаем контейнер и подключаем к нему Volume:
```
docker run --rm --name mysql_docker -e MYSQL_DATABASE=test_db -e MYSQL_ROOT_PASSWORD=my-pass -d -p 3306:3306 -v mysql_volume:/etc/mysql/ -v $PWD/backup:/backup mysql:8
```
Восстанавливаем данные из файла в базу данных:
```
docker exec -it mysql_docker bash -c 'mysql -uroot -pmy-pass test_db < /backup/backup.sql'
```
Переходим в управляющую консоль `mysql` внутри контейнера. 
```
docker exec -it mysql_docker mysql -uroot -pmy-pass test_db

mysql: [Warning] Using a password on the command line interface can be insecure.
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 12
Server version: 8.0.29 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```
Выполняем команду `\h`
```
mysql> \h

For information about MySQL products and services, visit:
   http://www.mysql.com/
For developer information, including the MySQL Reference Manual, visit:
   http://dev.mysql.com/
To buy MySQL Enterprise support, training, or other products, visit:
   https://shop.mysql.com/

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
exit      (\q) Exit mysql. Same as quit.
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument.
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.
resetconnection(\x) Clean session context.
query_attributes Sets string parameters (name1 value1 name2 value2 ...) for the next query to pick up.
ssl_session_data_print Serializes the current SSL session data to stdout or file

For server side help, type 'help contents'

```
Команда вывода статуса БД  
status    (\s) Get status information from the server.
```
Server version:		8.0.29 MySQL Community Server - GPL
```
Подключаемся к базе данных:
```
docker exec -it mysql_docker bash -c 'mysql -uroot -pmy-pass test_db'
```
Выводим список табиц:
```
mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```
Вывод количества строк со значением price>300:
```
mysql> select count(*) from orders where price>300;
+----------+
| count(*) |
+----------+
|        1 |
+----------+
1 row in set (0.01 sec)
```
## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привилегии пользователю `test` на операции SELECT базы `test_db`.
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.
---
_Ответ:_  
Создаем пользователя с заданными параметрами:
```
CREATE USER 'test'@'localhost' 
    IDENTIFIED WITH mysql_native_password BY 'test-pass'
    WITH MAX_CONNECTIONS_PER_HOUR 100
    PASSWORD EXPIRE INTERVAL 180 DAY
    FAILED_LOGIN_ATTEMPTS 3
    ATTRIBUTE '{"first_name":"James", "last_name":"Pretty"}';
```
Назначаем права на операцию SELECT в базе данных test_db:
```
GRANT SELECT ON test_db.* TO test;
```
Читаем атрибуты пользователя `test`:
```
SELECT ATTRIBUTE->>"$.first_name" AS first_name
    , ATTRIBUTE->>"$.last_name" AS last_name
    FROM INFORMATION_SCHEMA.USER_ATTRIBUTES
    WHERE USER='test' AND HOST='localhost';

+------------+-----------+
| first_name | last_name |
+------------+-----------+
| James      | Pretty    |
+------------+-----------+
1 row in set (0.00 sec)

```
---
## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.


---


---