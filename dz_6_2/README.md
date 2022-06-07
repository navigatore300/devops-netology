1. Q1
```
userr@home-srv:~$ docker pull postgres:12
12: Pulling from library/postgres
42c077c10790: Pull complete
3c2843bc3122: Pull complete
12e1d6a2dd60: Pull complete
9ae1101c4068: Pull complete
fb05d2fd4701: Pull complete
9785a964a677: Pull complete
16fc798b0e72: Pull complete
f1a0bfa2327a: Pull complete
f1e20d84ae82: Pull complete
8b37d1e969e5: Pull complete
7261decb0bcf: Pull complete
76fd4336668c: Pull complete
50b8a43577a4: Pull complete
Digest: sha256:fe84844ef27aaaa52f6ec68d6b3c225d19eb4f54200a93466aa67798c99aa462
Status: Downloaded newer image for postgres:12
docker.io/library/postgres:12
userr@home-srv:~$ docker volume create db_pg_data
db_pg_data
userr@home-srv:~$ docker volume create db_pg_data_backup
db_pg_data_backup
userr@home-srv:~$ docker run --rm --name pg-docker -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 -v db_pg_data:/var/lib/postgresql/data -v db_pg_data_backup:/media/postgresql/backup postgres:12
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.utf8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory /var/lib/postgresql/data ... ok
creating subdirectories ... ok
selecting dynamic shared memory implementation ... posix
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting default time zone ... Etc/UTC
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok

initdb: warning: enabling "trust" authentication for local connections
You can change this by editing pg_hba.conf or using the option -A, or
--auth-local and --auth-host, the next time you run initdb.

Success. You can now start the database server using:

    pg_ctl -D /var/lib/postgresql/data -l logfile start

waiting for server to start....2022-06-07 19:49:05.974 UTC [48] LOG:  starting PostgreSQL 12.11 (Debian 12.11-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
2022-06-07 19:49:05.976 UTC [48] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2022-06-07 19:49:06.005 UTC [49] LOG:  database system was shut down at 2022-06-07 19:49:05 UTC
2022-06-07 19:49:06.014 UTC [48] LOG:  database system is ready to accept connections
 done
server started

/usr/local/bin/docker-entrypoint.sh: ignoring /docker-entrypoint-initdb.d/*

2022-06-07 19:49:06.146 UTC [48] LOG:  received fast shutdown request
waiting for server to shut down....2022-06-07 19:49:06.151 UTC [48] LOG:  aborting any active transactions
2022-06-07 19:49:06.153 UTC [48] LOG:  background worker "logical replication launcher" (PID 55) exited with exit code 1
2022-06-07 19:49:06.154 UTC [50] LOG:  shutting down
2022-06-07 19:49:06.178 UTC [48] LOG:  database system is shut down
 done
server stopped

PostgreSQL init process complete; ready for start up.

2022-06-07 19:49:06.267 UTC [1] LOG:  starting PostgreSQL 12.11 (Debian 12.11-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
2022-06-07 19:49:06.267 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2022-06-07 19:49:06.267 UTC [1] LOG:  listening on IPv6 address "::", port 5432
2022-06-07 19:49:06.275 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2022-06-07 19:49:06.303 UTC [67] LOG:  database system was shut down at 2022-06-07 19:49:06 UTC
2022-06-07 19:49:06.312 UTC [1] LOG:  database system is ready to accept connections


userr@home-srv:~$ docker exec -it pg-docker psql -U postgres -d postgres
psql (12.11 (Debian 12.11-1.pgdg110+1))
Type "help" for help.

postgres=#

```