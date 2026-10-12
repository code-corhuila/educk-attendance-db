-- Apply immutable migrations in order on an empty local database.
\i /migrations/01_ddl/V1__init_attendance.sql
\i /migrations/01_ddl/V3__outbox_events_schema.sql
\i /migrations/04_alter/V4__align_attendance_runtime.sql
