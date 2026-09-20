-- init.sql for docker-entrypoint
\i /docker-entrypoint-initdb.d/migrations/V1__init_attendance.sql
\i /docker-entrypoint-initdb.d/seeds/01_seed_attendance.sql
