# Annex J deployment

The infrastructure owns PostgreSQL, its volume, pgcrypto and roles. This repository
only migrates attendance, authenticated as attendance_migrator. The API uses
attendance_app with DML grants, without superuser or schema creation privileges.
Flyway history is attendance.flyway_schema_history; the app cannot modify it.

Run the attendance-db-migrate service from the infrastructure Compose. Re-running
applies only pending versions. Applied SQL files remain byte-for-byte unchanged.
Historic CREATE EXTENSION IF NOT EXISTS statements are retained for checksum
compatibility; pgcrypto must already exist, owned and initialized by infrastructure.

This executor targets a new shared instance. Do not point it at an existing
nonempty domain without checking its Flyway history and taking a backup. Import
from old per-domain instances requires a separately validated data migration;
never reset or delete the original volumes.
